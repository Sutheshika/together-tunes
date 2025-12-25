const { Client } = require('pg');
require('dotenv').config();

async function testConnection() {
  // Extract connection details from DATABASE_URL
  const connectionString = process.env.DATABASE_URL;
  
  if (!connectionString) {
    console.error('❌ DATABASE_URL not found in .env file');
    return;
  }

  console.log('🔍 Testing PostgreSQL connection...');
  console.log('📝 Connection string:', connectionString.replace(/\/\/([^:]+):([^@]+)@/, '//***:***@'));

  const client = new Client({
    connectionString: connectionString
  });

  try {
    await client.connect();
    console.log('✅ Successfully connected to PostgreSQL!');
    
    // Test query
    const result = await client.query('SELECT NOW() as current_time');
    console.log('⏰ Database time:', result.rows[0].current_time);
    
    // Check if database exists and is accessible
    const dbResult = await client.query('SELECT current_database()');
    console.log('🗄️  Connected to database:', dbResult.rows[0].current_database);
    
  } catch (error) {
    console.error('❌ Database connection failed:');
    console.error('Error message:', error.message);
    console.error('Error code:', error.code);
    
    if (error.code === 'ENOTFOUND') {
      console.log('💡 Suggestion: Check if PostgreSQL server is running');
    } else if (error.code === '28P01') {
      console.log('💡 Suggestion: Check username/password in DATABASE_URL');
    } else if (error.code === '3D000') {
      console.log('💡 Suggestion: Database "together_tunes" does not exist. Create it first.');
    }
  } finally {
    await client.end();
  }
}

testConnection();