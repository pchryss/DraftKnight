import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();


export const updateWeeklyLeaderboard = onDocumentCreated("users/{userId}/games/{gameId}", async (event) => {
  console.log("starting")

  const newGame = event.data?.data();
  if (!newGame || typeof newGame.score !== "number") {
    console.log("No score found in new game document");
    return;
  }

  const score = newGame.score;
  const userId = event.params.userId;
    const timestamp: admin.firestore.Timestamp = newGame.data || admin.firestore.Timestamp.now();

    const weekID = getCurrentWeekID(timestamp);
  const leaderboardRef = db.collection("weekly_leaderboards").doc(weekID);
  const topScoresRef = leaderboardRef.collection("topScores");

  await topScoresRef.add({
    userId,
    score,
    timestamp,
  });

  const snapshot = await topScoresRef.orderBy("score", "desc").get();

  if (snapshot.size > 10) {
    const docsToDelete = snapshot.docs.slice(10);
    const batch = db.batch();
    docsToDelete.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    console.log(`Cleaned up ${docsToDelete.length} scores from leaderboard`);
  }

  console.log(`Updated weekly leaderboard for week ${weekID} with score ${score}`);
});

function getCurrentWeekID(timestamp: admin.firestore.Timestamp): string {
  const date = timestamp.toDate();
  const { year, week } = getISOWeek(date);
  return `${year}-W${week.toString().padStart(2, "0")}`;
}

function getISOWeek(date: Date): { year: number, week: number } {
  const tmpDate = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = tmpDate.getUTCDay() === 0 ? 7 : tmpDate.getUTCDay();
  tmpDate.setUTCDate(tmpDate.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(tmpDate.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil(((tmpDate.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);

  return { year: tmpDate.getUTCFullYear(), week: weekNo };
}


