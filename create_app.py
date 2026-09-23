import os

BASE = r"C:\Users\zaFORpsil\OneDrive\Desktop\SkaryChatApp"

def write(path, content):
    full = os.path.join(BASE, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"[+] {path}")

# ============ API CLIENT ============
write("src/api/api.ts", '''
import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";

const API_URL = "https://skarychat.onrender.com";

const api = axios.create({
  baseURL: API_URL,
  timeout: 10000,
});

api.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const register = async (username: string, password: string) => {
  const res = await api.post("/api/register", { username, password });
  return res.data;
};

export const login = async (username: string, password: string) => {
  const res = await api.post("/api/login", { username, password });
  await AsyncStorage.setItem("token", res.data.access_token);
  return res.data;
};

export const getMe = async () => {
  const res = await api.get("/api/me");
  return res.data;
};

export const getChats = async () => {
  const res = await api.get("/api/chats");
  return res.data;
};

export const createChat = async (name: string, members: number[] = [], isChannel: boolean = false) => {
  const res = await api.post("/api/chats", { name, members, is_channel: isChannel });
  return res.data;
};

export const getMessages = async (chatId: number) => {
  const res = await api.get(`/api/messages/${chatId}`);
  return res.data;
};

export const sendMessage = async (chatId: number, text: string) => {
  const res = await api.post("/api/messages", { chat_id: chatId, text });
  return res.data;
};

export const getUsers = async () => {
  const res = await api.get("/api/users");
  return res.data;
};

export const logout = async () => {
  await AsyncStorage.removeItem("token");
};

export default api;
''')

# ============ LOGIN SCREEN ============
write("src/screens/LoginScreen.tsx", '''
import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { login } from "../api/api";

export default function LoginScreen({ navigation }: any) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = async () => {
    if (!username || !password) {
      Alert.alert("Ошибка", "Заполни все поля");
      return;
    }
    try {
      await login(username, password);
      navigation.replace("Chats");
    } catch (e: any) {
      Alert.alert("Ошибка", e.response?.data?.detail || "Не удалось войти");
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>SkaryChat</Text>
      <Text style={styles.subtitle}>by Vitaly</Text>

      <TextInput
        style={styles.input}
        placeholder="Логин"
        placeholderTextColor="#666"
        value={username}
        onChangeText={setUsername}
      />
      <TextInput
        style={styles.input}
        placeholder="Пароль"
        placeholderTextColor="#666"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />

      <TouchableOpacity style={styles.button} onPress={handleLogin}>
        <Text style={styles.buttonText}>Войти</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => navigation.navigate("Register")}>
        <Text style={styles.link}>Зарегистрироваться</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#0A0A12", justifyContent: "center", padding: 20 },
  title: { fontSize: 42, fontWeight: "bold", color: "#00A2FF", textAlign: "center" },
  subtitle: { fontSize: 14, color: "#555", textAlign: "center", marginBottom: 40 },
  input: { backgroundColor: "#12121A", color: "#FFF", padding: 15, borderRadius: 10, marginBottom: 15, fontSize: 16 },
  button: { backgroundColor: "#00A2FF", padding: 15, borderRadius: 10, alignItems: "center", marginTop: 10 },
  buttonText: { color: "#FFF", fontSize: 18, fontWeight: "bold" },
  link: { color: "#00A2FF", textAlign: "center", marginTop: 20, fontSize: 16 },
});
''')

# ============ REGISTER SCREEN ============
write("src/screens/RegisterScreen.tsx", '''
import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { register } from "../api/api";

export default function RegisterScreen({ navigation }: any) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const handleRegister = async () => {
    if (!username || !password) {
      Alert.alert("Ошибка", "Заполни все поля");
      return;
    }
    try {
      await register(username, password);
      Alert.alert("Успех", "Аккаунт создан!");
      navigation.replace("Login");
    } catch (e: any) {
      Alert.alert("Ошибка", e.response?.data?.detail || "Не удалось зарегистрироваться");
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Регистрация</Text>

      <TextInput
        style={styles.input}
        placeholder="Логин"
        placeholderTextColor="#666"
        value={username}
        onChangeText={setUsername}
      />
      <TextInput
        style={styles.input}
        placeholder="Пароль"
        placeholderTextColor="#666"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />

      <TouchableOpacity style={styles.button} onPress={handleRegister}>
        <Text style={styles.buttonText}>Создать</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => navigation.goBack()}>
        <Text style={styles.link}>Назад</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#0A0A12", justifyContent: "center", padding: 20 },
  title: { fontSize: 32, fontWeight: "bold", color: "#00A2FF", textAlign: "center", marginBottom: 40 },
  input: { backgroundColor: "#12121A", color: "#FFF", padding: 15, borderRadius: 10, marginBottom: 15, fontSize: 16 },
  button: { backgroundColor: "#00A2FF", padding: 15, borderRadius: 10, alignItems: "center", marginTop: 10 },
  buttonText: { color: "#FFF", fontSize: 18, fontWeight: "bold" },
  link: { color: "#00A2FF", textAlign: "center", marginTop: 20, fontSize: 16 },
});
''')

# ============ CHATS SCREEN ============
write("src/screens/ChatsScreen.tsx", '''
import React, { useEffect, useState } from "react";
import { View, Text, FlatList, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { getChats, createChat } from "../api/api";

export default function ChatsScreen({ navigation }: any) {
  const [chats, setChats] = useState<any[]>([]);

  const loadChats = async () => {
    try {
      const data = await getChats();
      setChats(data);
    } catch (e) {
      console.log("Ошибка загрузки чатов");
    }
  };

  useEffect(() => {
    loadChats();
    const interval = setInterval(loadChats, 3000);
    return () => clearInterval(interval);
  }, []);

  const handleCreate = async () => {
    try {
      await createChat("Новый чат");
      loadChats();
    } catch (e) {
      Alert.alert("Ошибка", "Не удалось создать чат");
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Чаты</Text>
        <TouchableOpacity onPress={handleCreate}>
          <Text style={styles.addButton}>+</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={chats}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.chatItem}
            onPress={() => navigation.navigate("Chat", { chat: item })}
          >
            <Text style={styles.chatName}>{item.name}</Text>
          </TouchableOpacity>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#0A0A12" },
  header: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", padding: 20 },
  title: { fontSize: 32, fontWeight: "bold", color: "#FFF" },
  addButton: { fontSize: 40, color: "#00A2FF" },
  chatItem: { padding: 15, borderBottomWidth: 1, borderBottomColor: "#1A1A2E" },
  chatName: { color: "#FFF", fontSize: 18 },
});
''')

# ============ CHAT SCREEN ============
write("src/screens/ChatScreen.tsx", '''
import React, { useEffect, useState } from "react";
import { View, Text, TextInput, TouchableOpacity, FlatList, StyleSheet, KeyboardAvoidingView, Platform } from "react-native";
import { getMessages, sendMessage } from "../api/api";

export default function ChatScreen({ route }: any) {
  const { chat } = route.params;
  const [messages, setMessages] = useState<any[]>([]);
  const [text, setText] = useState("");

  const loadMessages = async () => {
    try {
      const data = await getMessages(chat.id);
      setMessages(data);
    } catch (e) {
      console.log("Ошибка загрузки сообщений");
    }
  };

  useEffect(() => {
    loadMessages();
    const interval = setInterval(loadMessages, 2000);
    return () => clearInterval(interval);
  }, []);

  const handleSend = async () => {
    if (!text.trim()) return;
    try {
      await sendMessage(chat.id, text);
      setText("");
      loadMessages();
    } catch (e) {
      console.log("Ошибка отправки");
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === "ios" ? "padding" : undefined}
    >
      <Text style={styles.chatTitle}>{chat.name}</Text>

      <FlatList
        data={messages}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <View style={styles.message}>
            <Text style={styles.messageAuthor}>{item.username}</Text>
            <Text style={styles.messageText}>{item.text}</Text>
          </View>
        )}
        style={styles.messages}
      />

      <View style={styles.inputRow}>
        <TextInput
          style={styles.input}
          placeholder="Сообщение..."
          placeholderTextColor="#666"
          value={text}
          onChangeText={setText}
        />
        <TouchableOpacity style={styles.sendButton} onPress={handleSend}>
          <Text style={styles.sendText}>→</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#0A0A12" },
  chatTitle: { fontSize: 20, fontWeight: "bold", color: "#FFF", padding: 15, borderBottomWidth: 1, borderBottomColor: "#1A1A2E" },
  messages: { flex: 1, padding: 10 },
  message: { backgroundColor: "#12121A", padding: 10, borderRadius: 10, marginBottom: 8 },
  messageAuthor: { color: "#00A2FF", fontSize: 12, marginBottom: 4 },
  messageText: { color: "#FFF", fontSize: 16 },
  inputRow: { flexDirection: "row", padding: 10, borderTopWidth: 1, borderTopColor: "#1A1A2E" },
  input: { flex: 1, backgroundColor: "#12121A", color: "#FFF", padding: 12, borderRadius: 20, fontSize: 16 },
  sendButton: { backgroundColor: "#00A2FF", width: 50, height: 50, borderRadius: 25, alignItems: "center", justifyContent: "center", marginLeft: 10 },
  sendText: { color: "#FFF", fontSize: 24, fontWeight: "bold" },
});
''')

# ============ PROFILE SCREEN ============
write("src/screens/ProfileScreen.tsx", '''
import React, { useEffect, useState } from "react";
import { View, Text, TouchableOpacity, StyleSheet } from "react-native";
import { getMe, logout } from "../api/api";

export default function ProfileScreen({ navigation }: any) {
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    getMe().then(setUser).catch(() => {});
  }, []);

  const handleLogout = async () => {
    await logout();
    navigation.replace("Login");
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Профиль</Text>
      {user && (
        <>
          <Text style={styles.username}>{user.username}</Text>
        </>
      )}

      <TouchableOpacity style={styles.button} onPress={handleLogout}>
        <Text style={styles.buttonText}>Выйти</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#0A0A12", padding: 20, justifyContent: "center" },
  title: { fontSize: 32, fontWeight: "bold", color: "#00A2FF", textAlign: "center", marginBottom: 40 },
  username: { fontSize: 24, color: "#FFF", textAlign: "center", marginBottom: 40 },
  button: { backgroundColor: "#FF3333", padding: 15, borderRadius: 10, alignItems: "center" },
  buttonText: { color: "#FFF", fontSize: 18, fontWeight: "bold" },
});
''')

# ============ APP.TSX ============
write("App.tsx", '''
import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import LoginScreen from "./src/screens/LoginScreen";
import RegisterScreen from "./src/screens/RegisterScreen";
import ChatsScreen from "./src/screens/ChatsScreen";
import ChatScreen from "./src/screens/ChatScreen";
import ProfileScreen from "./src/screens/ProfileScreen";

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Login"
        screenOptions={{
          headerStyle: { backgroundColor: "#0A0A12" },
          headerTintColor: "#00A2FF",
          headerTitleStyle: { fontWeight: "bold" },
        }}
      >
        <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Register" component={RegisterScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Chats" component={ChatsScreen} options={{ title: "SkaryChat" }} />
        <Stack.Screen name="Chat" component={ChatScreen} />
        <Stack.Screen name="Profile" component={ProfileScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
''')

print("\\n========================================")
print("ГОТОВО! ВСЕ ФАЙЛЫ СОЗДАНЫ!")
print("Теперь запусти:")
print("  npx react-native run-android")
print("========================================")