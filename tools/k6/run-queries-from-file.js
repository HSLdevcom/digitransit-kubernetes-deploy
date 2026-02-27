import http from 'k6/http';
import { check } from 'k6';
import { vu } from 'k6/execution';
import csv from 'k6/experimental/csv';
import { open } from 'k6/experimental/fs';

function requiredEnv(name) {
  const value = __ENV[name];
  if (value === undefined || value === "") {
    throw new Error(`Environment variable ${name} is required and must be non-empty`);
  }
  return value;
}

const API_URL = requiredEnv("API_URL");

export const options = {
  vus: 1,
  duration: '10s',
};

const file = await open('./queries.csv');
const queries = await csv.parse(file, { delimiter: ',' });

export default function () {
  const vuIndexOffset = queries.length / options.vus;
  const vuIndex = (vu.idInTest - 1);
  // Start at different places in the array for different virtual users (vu.idInTest is 1-based).
  const index = Math.floor(vuIndex * vuIndexOffset + vu.iterationInInstance) % queries.length;
  const row = queries[index];

  const payload = JSON.stringify({
    query: row[0],
    variables: JSON.parse(row[1]),
  });

  const res = http.post(
    API_URL,
    payload,
    { headers: { 'Content-Type': 'application/json' } }
  );

  check(res, {
    'status is 200': (r) => r.status === 200,
    'no GraphQL errors': (r) => !r.json().errors,
  });
}
