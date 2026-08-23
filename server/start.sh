#!/bin/sh
npx prisma db push --accept-data-loss
npm run db:seed
node server.js
