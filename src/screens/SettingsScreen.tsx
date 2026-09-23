import React, { useState } from "react";
import { View, Text, StyleSheet, Switch, ScrollView } from "react-native";

export default function SettingsScreen() {
  const [notifications, setNotifications] = useState(true);
  const [sounds, setSounds] = useState(true);
  const [vibration, setVibration] = useState(true);

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Настройки</Text>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Уведомления</Text>
        <View style={styles.row}>
          <Text style={styles.label}>Push-уведомления</Text>
          <Switch value={notifications} onValueChange={setNotifications} />
        </View>
        <View style={styles.row}>
          <Text style={styles.label}>Звуки</Text>
          <Switch value={sounds} onValueChange={setSounds} />
        </View>
        <View style={styles.row}>
          <Text style={styles.label}>Вибрация</Text>
          <Switch value={vibration} onValueChange={setVibration} />
        </View>
      </View>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>О приложении</Text>
        <Text style={styles.info}>NEXUSCHAT v1.0.0</Text>
        <Text style={styles.info}>by Vitaly</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#17212B", padding: 20 },
  title: { fontSize: 32, fontWeight: "bold", color: "#2AABEE", textAlign: "center", marginBottom: 30 },
  section: { marginBottom: 25 },
  sectionTitle: { color: "#2AABEE", fontSize: 18, fontWeight: "bold", marginBottom: 15 },
  row: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", paddingVertical: 10 },
  label: { color: "#FFF", fontSize: 16 },
  info: { color: "#708499", fontSize: 14, textAlign: "center", marginBottom: 5 },
});

