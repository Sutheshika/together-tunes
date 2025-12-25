const { Client } = require('pg');

const commonPasswords = ['postgres', 'admin', 'root', 'password', '', '123456', 'Admin'];

async function tryPasswords() {
  console.log('🔍 Testing common PostgreSQL passwords...\n');
  
  for (const password of commonPasswords) {
    const connectionString = `postgresql://postgres:${password}@localhost:5432/postgres`;
    const client = new Client({ connectionString });
    
    try {
      console.log(`Trying password: "${password || '(empty)'}"`);
      await client.connect();
      console.log(`✅ SUCCESS! Password is: "${password || '(empty)'}"`);
      console.log(`🔗 Working connection string: ${connectionString}`);
      await client.end();
      return password;
    } catch (error) {
      console.log(`❌ Failed with "${password || '(empty)'}"`);
      await client.end().catch(() => {});
    }
  }
  
  console.log('\n❌ None of the common passwords worked.');
  console.log('💡 You may need to:');
  console.log('   1. Check your PostgreSQL installation');
  console.log('   2. Reset the postgres user password');
  console.log('   3. Use pgAdmin to connect and check settings');
}

tryPasswords();