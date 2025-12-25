const { Client } = require('pg');
require('dotenv').config();

async function setupDatabase() {
  // First connect to the default postgres database
  const client = new Client({
    connectionString: "postgresql://postgres:2002@localhost:5432/postgres"
  });

  try {
    await client.connect();
    console.log('✅ Connected to PostgreSQL');

    // Check if together_tunes database exists
    const checkDb = await client.query(`
      SELECT datname FROM pg_catalog.pg_database 
      WHERE datname = 'together_tunes'
    `);

    if (checkDb.rows.length === 0) {
      console.log('📝 Creating together_tunes database...');
      await client.query('CREATE DATABASE together_tunes');
      console.log('✅ Database "together_tunes" created successfully!');
    } else {
      console.log('✅ Database "together_tunes" already exists');
    }

  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
  } finally {
    await client.end();
  }

  // Now test connection to the together_tunes database
  console.log('\n🔍 Testing connection to together_tunes database...');
  const appClient = new Client({
    connectionString: "postgresql://postgres:2002@localhost:5432/together_tunes"
  });

  try {
    await appClient.connect();
    console.log('✅ Successfully connected to together_tunes database!');
    
    const result = await appClient.query('SELECT NOW() as current_time');
    console.log('⏰ Database time:', result.rows[0].current_time);
    
  } catch (error) {
    console.error('❌ Connection to together_tunes failed:', error.message);
  } finally {
    await appClient.end();
  }
}

setupDatabase();