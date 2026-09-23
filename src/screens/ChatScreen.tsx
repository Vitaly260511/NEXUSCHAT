import React, { useEffect, useState, useRef } from "react";
import { View, Text, TextInput, TouchableOpacity, FlatList, StyleSheet, KeyboardAvoidingView, Platform, Alert, Modal } from "react-native";
import { getMessages, sendMessage, addReaction, deleteMessage, editMessage } from "../api/api";
import MessageBubble from "../components/MessageBubble";

export default function ChatScreen({ route }: any) {
  const { chat } = route.params;
  const [messages, setMessages] = useState<any[]>([]);
  const [text, setText] = useState("");
  const [editing, setEditing] = useState<any>(null);
  const [selected, setSelected] = useState<any>(null);
  const [modalVisible, setModalVisible] = useState(false);
  const flatListRef = useRef<FlatList>(null);

  const loadMessages = async () => {
    try {
      const data = await getMessages(chat.id);
      setMessages(data);
    } catch (e) {}
  };

  useEffect(() => {
    loadMessages();
    const interval = setInterval(loadMessages, 2000);
    return () => clearInterval(interval);
  }, []);

  const handleSend = async () => {
    if (!text.trim()) return;
    try {
      if (editing) {
        await editMessage(editing.id, text);
        setEditing(null);
      } else {
        await sendMessage(chat.id, text);
      }
      setText("");
      loadMessages();
      flatListRef.current?.scrollToEnd();
    } catch (e) {}
  };

  const handleLongPress = (msg: any) => {
    setSelected(msg);
    setModalVisible(true);
  };

  const handleReaction = async (emoji: string) => {
    if (selected) {
      await addReaction(selected.id, emoji);
      setModalVisible(false);
      loadMessages();
    }
  };

  const handleDelete = async () => {
    if (selected) {
      Alert.alert("Удалить", "Удалить сообщение?", [
        { text: "Нет", style: "cancel" },
        { text: "Да", style: "destructive", onPress: async () => { await deleteMessage(selected.id); setModalVisible(false); loadMessages(); } },
      ]);
    }
  };

  const handleEdit = () => {
    if (selected) { setEditing(selected); setText(selected.text); setModalVisible(false); }
  };

  return (
    <KeyboardAvoidingView style={styles.container} behavior={Platform.OS === "ios" ? "padding" : undefined}>
      <Text style={styles.chatTitle}>{chat.name}</Text>
      <FlatList
        ref={flatListRef}
        data={messages}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <TouchableOpacity onLongPress={() => handleLongPress(item)}>
            <MessageBubble message={item} isOwn={item.is_own} />
          </TouchableOpacity>
        )}
        style={styles.messages}
      />
      {editing && (
        <View style={styles.editingBar}>
          <Text style={styles.editingText}>Редактирование</Text>
          <TouchableOpacity onPress={() => { setEditing(null); setText(""); }}>
            <Text style={styles.cancelEdit}>✕</Text>
          </TouchableOpacity>
        </View>
      )}
      <View style={styles.inputRow}>
        <TextInput style={styles.input} placeholder="Сообщение..." placeholderTextColor="#708499" value={text} onChangeText={setText} multiline />
        <TouchableOpacity style={styles.sendButton} onPress={handleSend}>
          <Text style={styles.sendText}>➤</Text>
        </TouchableOpacity>
      </View>
      <Modal visible={modalVisible} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Действия</Text>
            <View style={styles.reactionsRow}>
              {["👍", "❤️", "😂", "😮", "😢", "🔥"].map((emoji) => (
                <TouchableOpacity key={emoji} onPress={() => handleReaction(emoji)}>
                  <Text style={styles.reactionBtn}>{emoji}</Text>
                </TouchableOpacity>
              ))}
            </View>
            <TouchableOpacity style={styles.modalBtn} onPress={handleEdit}>
              <Text style={styles.modalBtnText}>✏️ Редактировать</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.modalBtn} onPress={handleDelete}>
              <Text style={styles.modalBtnText}>🗑️ Удалить</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.modalBtn} onPress={() => setModalVisible(false)}>
              <Text style={styles.modalBtnText}>Отмена</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#0E1621" },
  chatTitle: { fontSize: 18, fontWeight: "bold", color: "#FFF", padding: 15, backgroundColor: "#17212B", borderBottomWidth: 1, borderBottomColor: "#101921" },
  messages: { flex: 1, padding: 10 },
  inputRow: { flexDirection: "row", padding: 10, backgroundColor: "#17212B", alignItems: "flex-end" },
  input: { flex: 1, backgroundColor: "#0E1621", color: "#FFF", padding: 12, borderRadius: 20, fontSize: 16, maxHeight: 100 },
  sendButton: { backgroundColor: "#2AABEE", width: 44, height: 44, borderRadius: 22, alignItems: "center", justifyContent: "center", marginLeft: 8 },
  sendText: { color: "#FFF", fontSize: 20 },
  editingBar: { flexDirection: "row", justifyContent: "space-between", padding: 10, backgroundColor: "#1C2733" },
  editingText: { color: "#2AABEE", fontSize: 14 },
  cancelEdit: { color: "#FF3333", fontSize: 18 },
  modalOverlay: { flex: 1, backgroundColor: "rgba(0,0,0,0.7)", justifyContent: "center", alignItems: "center" },
  modalContent: { backgroundColor: "#17212B", borderRadius: 15, padding: 20, width: "80%" },
  modalTitle: { color: "#FFF", fontSize: 18, fontWeight: "bold", marginBottom: 15, textAlign: "center" },
  reactionsRow: { flexDirection: "row", justifyContent: "space-around", marginBottom: 15 },
  reactionBtn: { fontSize: 28 },
  modalBtn: { padding: 12, borderTopWidth: 1, borderTopColor: "#101921" },
  modalBtnText: { color: "#FFF", fontSize: 16, textAlign: "center" },
});

