const { execSync, spawn } = require("child_process");
const readline = require("readline");

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

const c = {
  reset:  "\x1b[0m",
  cyan:   "\x1b[36m",
  white:  "\x1b[37m",
  dim:    "\x1b[2m",
  green:  "\x1b[32m",
  yellow: "\x1b[33m",
  red:    "\x1b[31m",
  gray:   "\x1b[90m",
};

function pingColor(ms) {
  if (ms === null) return c.gray;
  if (ms < 50)     return c.green;
  if (ms < 150)    return c.yellow;
  return c.red;
}

function formatLatency(t) {
  if (t === "*") return `${c.gray}${"*".padStart(7)}${c.reset}`;
  const ms  = parseInt(t);
  const col = pingColor(isNaN(ms) ? null : ms);
  return `${col}${t.padStart(7)}${c.reset}`;
}

function resolveIP(target) {
  try {
    const result = execSync(`nslookup ${target}`, { encoding: "utf8" });
    const match  = result.match(/Address:\s+([\d.]+)/g);
    if (match && match.length > 1) {
      return match[match.length - 1].replace("Address:", "").trim();
    }
  } catch (_) {}
  return null;
}

function trace(target) {
  console.log(`\n  ${c.cyan}Tracing ${target}${c.reset}\n`);
  console.log(`  ${"HOP".padEnd(5)}${"PING 1".padStart(7)}  ${"PING 2".padStart(7)}  ${"PING 3".padStart(7)}    ADDRESS`);
  console.log(`  ${c.dim}${"-".repeat(52)}${c.reset}`);

  let buffer = "";

  const proc = spawn("tracert", ["-d", target]);

  proc.stdout.on("data", (data) => {
    buffer += data.toString();
    const lines = buffer.split("\n");
    buffer = lines.pop();

    lines.forEach((line) => {
      line = line.trim();
      const hopMatch = line.match(/^\s*(\d+)\s+(<?\d+\s*ms|\*)\s+(<?\d+\s*ms|\*)\s+(<?\d+\s*ms|\*)\s*([\d.]+)?/);
      if (!hopMatch) return;

      const hop  = hopMatch[1].padEnd(5);
      const t1   = formatLatency(hopMatch[2].replace(/\s*ms/, "ms").trim());
      const t2   = formatLatency(hopMatch[3].replace(/\s*ms/, "ms").trim());
      const t3   = formatLatency(hopMatch[4].replace(/\s*ms/, "ms").trim());
      const addr = hopMatch[5]
        ? `${c.white}${hopMatch[5].trim()}${c.reset}`
        : `${c.gray}timed out${c.reset}`;

      console.log(`  ${c.dim}${hop}${c.reset}${t1}  ${t2}  ${t3}    ${addr}`);
    });
  });

  proc.on("close", () => {
    const ip = resolveIP(target);
    if (ip) console.log(`\n  ${c.cyan}Resolved IP:${c.reset} ${ip}`);
    console.log(`  ${c.dim}Trace complete.${c.reset}\n`);
    ask();
  });
}

function ask() {
  rl.question(`${c.cyan}Domain?${c.reset} ~$ `, (input) => {
    input = input.trim();
    if (!input) return ask();
    if (input === "exit" || input === "quit") {
      rl.close();
      return;
    }
    trace(input);
  });
}

ask();