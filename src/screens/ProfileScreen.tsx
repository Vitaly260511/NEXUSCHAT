import React, { useEffect, useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ScrollView, Alert, Switch } from "react-native";
import { getMe, logout, updateProfile, updateTheme, updatePrivacy } from "../api/api";

export default function ProfileScreen({ navigation }: any) {
  const [user, setUser] = useState<any>(null);
  const [bio, setBio] = useState("");
  const [theme, setTheme] = useState("dark");
  const [hideLastSeen, setHideLastSeen] = useState(false);
  const [hidePhone, setHidePhone] = useState(false);
  const [hideAvatar, setHideAvatar] = useState(false);

  useEffect(() => {
    getMe().then((data) => {
      setUser(data);
      setBio(data.bio || "");
      setTheme(data.theme || "dark");
    }).catch(() => {});
  }, []);

  const handleSaveBio = async () => {
    try { await updateProfile({ bio }); Alert.alert("Успех", "Био обновлено"); }
    catch (e) { Alert.alert("Ошибка", "Не удалось сохранить"); }
  };

  const handleLogout = async () => {
    await logout();
    navigation.replace("Login");
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Профиль</Text>
      {user && (
        <>
          <View style={styles.section}>
            <Text style={styles.label}>Имя пользователя</Text>
            <Text style={styles.value}>{user.username}</Text>
          </View>
          <View style={styles.section}>
            <Text style={styles.label}>Био</Text>
            <TextInput style={styles.input} value={bio} onChangeText={setBio} placeholder="Расскажи о себе..." placeholderTextColor="#708499" multiline />
            <TouchableOpacity style={styles.saveBtn} onPress={handleSaveBio}>
              <Text style={styles.saveBtnText}>Сохранить</Text>
            </TouchableOpacity>
          </View>
        </>
      )}
      <TouchableOpacity style={styles.logoutBtn} onPress={handleLogout}>
        <Text style={styles.logoutText}>Выйти</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#17212B", padding: 20 },
  title: { fontSize: 32, fontWeight: "bold", color: "#2AABEE", textAlign: "center", marginBottom: 30 },
  section: { marginBottom: 25 },
  label: { color: "#708499", fontSize: 14, marginBottom: 8 },
  value: { color: "#FFF", fontSize: 18 },
  input: { backgroundColor: "#0E1621", color: "#FFF", padding: 12, borderRadius: 10, fontSize: 16, minHeight: 80 },
  saveBtn: { backgroundColor: "#2AABEE", padding: 12, borderRadius: 10, alignItems: "center", marginTop: 10 },
  saveBtnText: { color: "#FFF", fontSize: 16, fontWeight: "bold" },
  logoutBtn: { backgroundColor: "#FF3333", padding: 15, borderRadius: 10, alignItems: "center", marginTop: 20 },
  logoutText: { color: "#FFF", fontSize: 18, fontWeight: "bold" },
});
