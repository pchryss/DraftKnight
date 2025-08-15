import * as admin from "firebase-admin";
import { onCall } from "firebase-functions/v2/https";


admin.initializeApp();
const db = admin.firestore();

interface Player {
  name: string;
  points: number;
  position: string;
  team: string;
  year: number;
}

interface Game {
  score: number;
  players: Player[]; 
  date: admin.firestore.Timestamp;
}

export const addGameToLeaderboard = onCall(async (request) => {
  try {
    const { userId, game } = request.data as { userId: string; game: Game };
    if (!userId || !game || !game.players.length) {
      return { success: false, error: "Invalid input" };
    }

    let timestamp: admin.firestore.Timestamp;
    if (typeof game.date === "string") {
      timestamp = admin.firestore.Timestamp.fromDate(new Date(game.date));
    } else {
      timestamp = game.date;
    }

    const weekID = getCurrentWeekID(timestamp);
    const leaderboardRef = db.collection("weekly_leaderboards").doc(weekID);
    const topScoresRef = leaderboardRef.collection("topScores");

    await topScoresRef.add({
      userId,
      score: game.score,
      players: game.players,
      timestamp
    });

    const snapshot = await topScoresRef.orderBy("score", "desc").orderBy("timestamp", "asc").get();
    if (snapshot.size > 10) {
      const batch = db.batch();
      snapshot.docs.slice(10).forEach(doc => batch.delete(doc.ref));
      await batch.commit();
    }

    return { success: true };
  } catch (err) {
    console.error("Error in addGameToLeaderboard:", err);
    return { success: false, error: (err as Error).message };
  }
});


function getCurrentWeekID(timestamp: admin.firestore.Timestamp): string {
  const date = timestamp.toDate();
  const { year, week } = getISOWeek(date);
  return `${year}-W${week.toString().padStart(2, "0")}`;
}

function getISOWeek(date: Date): { year: number; week: number } {
  const tmpDate = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = tmpDate.getUTCDay() === 0 ? 7 : tmpDate.getUTCDay();
  tmpDate.setUTCDate(tmpDate.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(tmpDate.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil(((tmpDate.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
  return { year: tmpDate.getUTCFullYear(), week: weekNo };
}