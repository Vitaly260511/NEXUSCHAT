import React, { useEffect, useState } from "react";
import { View, Text, FlatList, TouchableOpacity, StyleSheet, TextInput, Modal, Alert } from "react-native";
import { getChats, createChat } from "../api/api";
import ChatListItem from "../components/ChatListItem";

export default function ChatsScreen({ navigation }: any) {
  const [chats, setChats] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [modalVisible, setModalVisible] = useState(false);
  const [newChatName, setNewChatName] = useState("");

  const loadChats = async () => {
    try {
      const data = await getChats();
      setChats(data);
    } catch (e) {}
  };

  useEffect(() => {
    loadChats();
    const interval = setInterval(loadChats, 3000);
    return () => clearInterval(interval);
  }, []);

  const handleCreate = async () => {
    if (!newChatName.trim()) { Alert.alert("Ошибка", "Введи название"); return; }
    try {
      await createChat(newChatName);
      setNewChatName("");
      setModalVisible(false);
      loadChats();
    } catch (e) { Alert.alert("Ошибка", "Не удалось создать"); }
  };

  const filtered = chats.filter((c) => c.name?.toLowerCase().includes(search.toLowerCase()));

  return (
    <View style={styles.container}>
      <View style={styles.searchBar}>
        <Text style={styles.searchIcon}>🔍</Text>
        <TextInput style={styles.searchInput} placeholder="Поиск" placeholderTextColor="#708499" value={search} onChangeText={setSearch} />
      </View>
      <FlatList
        data={filtered}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <ChatListItem chat={item} onPress={() => navigation.navigate("Chat", { chat: item })} />
        )}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
      />
      <TouchableOpacity style={styles.fab} onPress={() => setModalVisible(true)}>
        <Text style={styles.fabIcon}>✏️</Text>
      </TouchableOpacity>
      <Modal visible={modalVisible} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Новый чат</Text>
            <TextInput style={styles.modalInput} placeholder="Название" placeholderTextColor="#708499" value={newChatName} onChangeText={setNewChatName} />
            <View style={styles.modalButtons}>
              <TouchableOpacity style={styles.modalButton} onPress={() => setModalVisible(false)}>
                <Text style={styles.modalButtonText}>Отмена</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.modalButton, styles.modalButtonPrimary]} onPress={handleCreate}>
                <Text style={styles.modalButtonText}>Создать</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#17212B" },
  searchBar: { flexDirection: "row", alignItems: "center", backgroundColor: "#0E1621", margin: 8, borderRadius: 10, paddingHorizontal: 12 },
  searchIcon: { fontSize: 16, marginRight: 8 },
  searchInput: { flex: 1, color: "#FFF", fontSize: 16, paddingVertical: 10 },
  separator: { height: 0.5, backgroundColor: "#101921", marginLeft: 78 },
  fab: { position: "absolute", bottom: 20, right: 20, width: 56, height: 56, borderRadius: 28, backgroundColor: "#2AABEE", alignItems: "center", justifyContent: "center", elevation: 5 },
  fabIcon: { fontSize: 24 },
  modalOverlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.5)", justifyContent: "flex-end" },
  modalContent: { backgroundColor: "#17212B", borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 20 },
  modalTitle: { color: "#FFF", fontSize: 20, fontWeight: "bold", marginBottom: 20 },
  modalInput: { backgroundColor: "#0E1621", color: "#FFF", padding: 15, borderRadius: 10, fontSize: 16, marginBottom: 20 },
  modalButtons: { flexDirection: "row", justifyContent: "flex-end", gap: 10 },
  modalButton: { paddingVertical: 12, paddingHorizontal: 20, borderRadius: 10 },
  modalButtonPrimary: { backgroundColor: "#2AABEE" },
  modalButtonText: { color: "#FFF", fontSize: 16, fontWeight: "bold" },
});
