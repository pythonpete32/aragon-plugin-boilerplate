import * as fs from "fs";
const data = fs.readFileSync("./data2.txt", "utf8");
const x = [0, 3, 6];
const score = (round: string[]) => {
  if (round[0] === "A" && round[1] === "X") return [7, 3];
  if (round[0] === "A" && round[1] === "Y") return [4, 4];
  if (round[0] === "A" && round[1] === "Z") return [1, 8];
  if (round[0] === "B" && round[1] === "X") return [8, 1];
  if (round[0] === "B" && round[1] === "Y") return [5, 5];
  if (round[0] === "B" && round[1] === "Z") return [2, 9];
  if (round[0] === "C" && round[1] === "X") return [9, 2];
  if (round[0] === "C" && round[1] === "Y") return [6, 6];
  if (round[0] === "C" && round[1] === "Z") return [3, 7];
};

console.log(
  data
    .split("\n")
    .map((round) => round.split(" "))
    .map((round) => score(round))
    .reduce(
      (p, c) => [(p?.[0] as number) + (c?.[0] as number), (p?.[1] as number) + (c?.[1] as number)],
      [0, 0]
    )
);

// console.log(
//   data
//     .split("\n\n")
//     .map((group) => group.replace(/\s/g, ""))
//     .map((group) => group.split(";"))
//     .map((group) => group.map((item) => Number(item)))
//     .map((group) => group.reduce((a, b) => a + b))
//     //.reduce((acc, num, index) => (acc[0] < num ? [num, index] : acc), [0, 0])
//     .map((item) => (item > Math.min(...top) ? (top[top.indexOf(Math.min(...top))] = item) : top))
// );
// console.log(top.reduce((a, b) => a + b));
