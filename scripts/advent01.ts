import * as fs from "fs";
const data = fs.readFileSync("./data.txt", "utf8");
// console.log(data);
const top = [0, 0, 0];
console.log(
  data
    .split("\n\n")
    .map((group) => group.replace(/\s/g, ""))
    .map((group) => group.split(";"))
    .map((group) => group.map((item) => Number(item)))
    .map((group) => group.reduce((a, b) => a + b))
    //.reduce((acc, num, index) => (acc[0] < num ? [num, index] : acc), [0, 0])
    .map((item) => (item > Math.min(...top) ? (top[top.indexOf(Math.min(...top))] = item) : top))
);
console.log(top.reduce((a, b) => a + b));
