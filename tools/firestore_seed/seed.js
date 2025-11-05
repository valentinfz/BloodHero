/*
 * Script de seed para popular Firestore con datos mínimos usados por la app.
 * Requiere:
 *   1. Ejecutar `npm install firebase-admin` en esta carpeta.
 *   2. Definir GOOGLE_APPLICATION_CREDENTIALS apuntando al json del service account.
 * Uso:
 *   node seed.js
 */

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const dataPath = path.resolve(__dirname, 'seed_data.json');
const payload = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error('GOOGLE_APPLICATION_CREDENTIALS no está definido.');
  process.exit(1);
}

admin.initializeApp();

(async () => {
  const db = admin.firestore();
  const batch = db.batch();

  console.log('Sobrescribiendo colección centers...');
  payload.centers.forEach((center) => {
    const ref = db.collection('centers').doc(center.id);
    batch.set(ref, {
      name: center.name,
      address: center.address,
      latitude: center.latitude,
      longitude: center.longitude,
      imageUrl: center.imageUrl,
      schedule: center.schedule,
      services: center.services,
      contact: center.contact,
    });
  });

  console.log('Sobrescribiendo colección achievementCatalog...');
  payload.achievementCatalog.forEach((achievement) => {
    const ref = db.collection('achievementCatalog').doc(achievement.id);
    batch.set(ref, {
      title: achievement.title,
      description: achievement.description,
      iconName: achievement.iconName,
    });
  });

  console.log('Sobrescribiendo colección alerts...');
  payload.alerts.forEach((alert) => {
    const ref = db.collection('alerts').doc(alert.id);
    batch.set(ref, {
      centerId: alert.centerId,
      bloodType: alert.bloodType,
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(alert.expiresAt),
      ),
      quantityNeeded: alert.quantityNeeded,
      description: alert.description,
      urgencyHours: alert.urgencyHours,
      contactPhone: alert.contactPhone,
      contactEmail: alert.contactEmail,
    });
  });

  await batch.commit();
  console.log('Seed completado.');
  process.exit(0);
})();
