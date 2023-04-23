<template>
  <div id="app">
    <main>


      <section class="player">
          <ais-instant-search :search-client="searchClient" index-name="songs">
              <template>
                  <ais-instant-search index-name="songs" :search-client="searchClient">
                      <ais-configure />
                      <ais-search-box
                              placeholder="Type Song Title or Artist"
                              :autofocus=true
                              :show-loading-indicator=true
                      />
                      <ais-hits :escape-HTML="true">
                          <div slot="item" slot-scope="{ item }">
                              <v-toolbar
                                      block
                                      dense
                                      elevation="10"
                                      x-small
                                      @click="replaceCurrent(item)"
                                      @keydown.enter="replaceCurrent(item)"
                              >
                                  <img class="cover-playlist" :src="item.image" />
                                  |
                                  <h5>{{ item.title }}</h5>
                                  |
                                  <h5>{{ item.bpm }}</h5>
                                  |
                                  <h5>{{ item.key }}</h5>
                              </v-toolbar>
                          </div>
                      </ais-hits>
                  </ais-instant-search>
              </template>
          </ais-instant-search>
        <div class="cover-wrapper">
          <img v-bind:class="coverObject" :src="current.cover" />
        </div>
        <div class="song-details">
          <h2 class="song-title">
            {{ current.title }}
          </h2>
          <!--                 {{ current.author }}     <p class="artist">{{ current.artist }}</p>-->
          <p class="artist">
            {{ current ? current.bpm.toFixed(1) : 0 }} | {{ current.key }}
            {{ current.scale }}
          </p>
          <p class="artist">
            danceability :
            {{ current ? current.danceability.toFixed(1) * 100 + "%" : 0 + " %" }}
            | energy :
            {{ current ? current.energy.toFixed(1) * 100 + "%" : 0 + " %" }}
          </p>
          <p class="artist">
            happy : {{ current ? current.happy.toFixed(1) * 100 + "%" : 0 + " %" }} | sad
            : {{ current.sad.toFixed(1) * 100 ?? 0 + " %" }}
          </p>
          <p class="artist"></p>
          <KProgress
            :show-text="false"
            class="progress-bar-wrapper"
            v-bind:percent="current.percent"
            :color="['#df83f1', '#82279f', '#53cfe0']"
          />
          <div class="timer">
            <p class="start">{{ currentlyTimer }}</p>
            <p class="end">
              {{ current.totalTimer }}
            </p>
          </div>
          <div class="timer">
            <button class="start" @click="previousPage" v-if="songs.offset > 1">
              Back
            </button>
          </div>
        </div>
        <div class="controls">
          <button class="prev" @click="prev" v-if="songs.length > 1">
            <font-awesome-icon icon="step-backward" />
          </button>
          <button class="play" v-if="!isPlaying" @click="play">
            <font-awesome-icon icon="play" />
          </button>
          <button class="pause" v-else @click="pause">
            <font-awesome-icon icon="pause" />
          </button>
          <button class="next" @click="next" v-if="songs.length > 1">
            <font-awesome-icon icon="step-forward" />
          </button>
        </div>
      </section>
    </main>
    <section class="playlist">
      <h3>Now Playing <span> 🎵 </span></h3>
      <ul>
        <li v-for="song in songs" :key="song.src" class="song">
          <div class="cover-playlist">
            <img class="cover" :src="song.cover" />
          </div>
          <div class="details" @click="play(song)">
            <h2 class="song-title">
              {{ song.title }}
            </h2>
            <p class="artist">
              {{ song.bpm }} | {{ song.key }} {{ song.scale }}
            </p>
            <p class="artist">
              danceability :
              {{ song.danceability.toFixed(1) * 100 + "%" ?? 0 + " %" }}
              | energy :
              {{ song.energy.toFixed(1) * 100 + "%" ?? 0 + " %" }}
            </p>
            <p class="artist">
              happy : {{ song.happy.toFixed(1) * 100 + "%" ?? 0 + " %" }}
            </p>
            <p class="artist">
              sad : {{ song.sad.toFixed(1) * 100 + "%" ?? 0 + " %" }}
            </p>
            <KProgress
              v-if="song.isPlaying"
              :color="['#df83f1', '#82279f', '#53cfe0']"
              :show-text="false"
              class="progress-bar-wrapper"
              v-bind:percent="song.percent"
            />

            <v-btn
              v-if="songs.indexOf(song) < songs.length - 1"
              x-small
              color="secondary"
              dark
            >
              {{ songs.indexOf(song) }} / {{ songs.length - 1 }}
            </v-btn>
            <!-- vuetify button -->
            <v-btn
                dark
                block
                elevation="10"
                small
                x-small
                v-else-if="songs.indexOf(song) >= songs.length - 1"
                color="primary"
                @click="nextPage(currentPage)"
            >
              Load More Songs
            </v-btn>
          </div>
          <div class="actions">
            <button @click="removeSongFromPlaylist(song)" class="delete">
              <font-awesome-icon icon="times" />
            </button>
          </div>
        </li>
      </ul>
    </section>
    <section class="playlist">
      <h3>Related / Similar Songs <span> 🎵 </span></h3>
      <ul>
        <li v-for="song in matches" :key="song.src" class="song">
          <div class="cover-playlist">
            <img class="cover" :src="song.cover" />
          </div>
          <div class="details" @click="playNext(song)">
            <h2 class="song-title">
              {{ song.title }}
            </h2>
            <!--            <p class="artist">{{ song.artist }}</p>-->
            <p class="artist">
              {{ song.bpm.toFixed(1) ?? 0 }} {{ song.key }} {{ song.scale }}
            </p>
            <p class="artist">
              danceability :
              {{ song.danceability.toFixed(1) * 100 + "%" ?? 0 + " %" }}
              | energy :
              {{ song.energy.toFixed(1) * 100 + "%" ?? 0 + " %" }}
            </p>
            <p class="artist">
              happy : {{ song.happy.toFixed(1) * 100 + "%" ?? 0 + " %" }}
            </p>
            <p class="artist">
              sad : {{ song.sad.toFixed(1) * 100 + "%" ?? 0 + " %" }}
            </p>
            <v-btn
              v-if="matches.indexOf(song) < matches.length - 1"
              x-small
              color="secondary"
              dark
            >
              {{ matches.indexOf(song) }} / {{ matches.length - 1 }}
            </v-btn>


            <KProgress
              v-if="song.isPlaying"
              :color="['#df83f1', '#82279f', '#53cfe0']"
              :show-text="false"
              class="progress-bar-wrapper"
              v-bind:percent="song.percent"
            />


            <v-btn
                dark
                block
                elevation="10"
                small
                x-small
                v-else-if="matches.indexOf(song) >= matches.length - 1"
                color="primary"
                @click="nextPage(currentPage)"
            >
              Load More Songs / Reshuffle
            </v-btn>
          </div>


          <div class="actions">
            <button @click="removeSongFromPlaylist(song)" class="delete">
              <font-awesome-icon icon="times" />
            </button>
          </div>
        </li>
      </ul>
    </section>
  </div>
</template>

<script>
import KProgress from "k-progress";

import { formatTimer } from "./helpers/timer";
import { deleteElement, shuffleArray, threatSongs } from "./helpers/utils";
import songs from "./mocks/songs";
import axios from "axios";
import { instantMeiliSearch } from "@meilisearch/instant-meilisearch";
import { AisInstantSearch, AisSearchBox } from "vue-instantsearch";
export default {
  components: {
    KProgress,
    AisInstantSearch,
    AisSearchBox
  },
  name: "App",

  data() {
    return {
      current: {},
      coverObject: { cover: true, animated: false },
      index: 0,
      isPlaying: false,
      currentlyTimer: "00:00",
      songs: shuffleArray(songs),
      matches: [],
      player: new Audio(),
      sucket: null,
      currentPage: 1,
      message: "",
      search: "",
      searchClient: instantMeiliSearch(
          "http://search.curator.atemkeng.eu" ?? "http://localhost:7700",
        "masterKey",
        {
          paginationTotalHits: 50, // default: 200.
          placeholderSearch: false, // default: true.
          primaryKey: "id" // default: undefined
          // ...
        },
        {
          limitPerRequest: 20, // default: 20.
          initialIndexUid: "songs" // default: undefined.
        }
      )
    };
  },
  methods: {
    listenersWhenPlay() {
      this.player.addEventListener("timeupdate", () => {
        var playerTimer = this.player.currentTime;

        this.currentlyTimer = formatTimer(playerTimer);
        this.current.percent = (playerTimer * 100) / this.current.seconds;
        this.current.isPlaying = true;
      });
      this.player.addEventListener(
        "ended",
        function() {
          this.next();
        }.bind(this)
      );
    },
    setCover() {
      this.coverObject.animated = true;

      setTimeout(() => {
        this.coverObject.animated = false;
      }, 1000);
    },
    setCurrentSong() {
      this.current = this.songs[this.index];
      this.play(this.current);
      this.setCover();
    },
    play(song) {
      console.log("FROM PLAY 1 ****************************");
        console.log(song)
      if (typeof song.src !== "undefined") {
        this.current.isPlaying = false;
        this.index = this.songs.indexOf(this.current);
        this.current = song;
        this.player.src = this.current.src;
      }
      this.matches = [];

      song.played = true;
      this.getRelatedSongs(song);

      this.player.play();
      this.isPlaying = true;

      this.setCover();
      this.listenersWhenPlay();
      this.sendData({
        id: song.id,
        title: song.title,
        related: song.related_songs
      });
    },
    playNext(song) {
      console.log(
        "FROM PLAY NEX 2 =================================================================================="
      );
      if (typeof song.src !== "undefined") {
        this.current.isPlaying = false;
        this.index = this.songs.indexOf(this.current);
        this.current = song;
        this.player.src = this.current.src;
      }
      this.songs = [];

      song.played = true;
      this.getNextRelatedSongs(song);

      this.player.play();
      this.isPlaying = true;

      this.setCover();
      this.listenersWhenPlay();
    },
    pause() {
      this.player.pause();
      this.isPlaying = false;
    },
    next() {
      this.current.isPlaying = false;
      this.index = this.songs.indexOf(this.current);
      this.index++;
      if (this.index > this.songs.length - 1) {
        this.index = 0;
      }
      this.setCurrentSong();
    },
    prev() {
      this.current.isPlaying = false;
      this.index = this.songs.indexOf(this.current);
      this.index--;
      if (this.index < 0) {
        this.index = this.songs.length - 1;
      }
      this.setCurrentSong();
    },
    removeSongFromPlaylist(song) {
      if (this.songs.length > 1) {
        if (this.index > 0) {
          this.index--;
        }
        this.current.isPlaying = false;
        this.songs = deleteElement(this.songs, song);
        this.setCurrentSong();
      }
    },
    async getAllSongFromApi(offset = 0, limit = 50) {
      console.log({ songs_before: this.songs.length, offset, limit });
      let baseUrl = "http://core.curator.atemkeng.eu/api" ?? "http://localhost:8899/api";
      let url =
        baseUrl + "/search/songs?offset=" +
        offset +
        "&limit=" +
        limit;
      let allSongs = await axios
        .get(url)
        .then(res => {
          let songs = res.data.data;

          songs.forEach(song => {
            let newSong = song;
            (newSong.title = song.title),
              (newSong.artist = song.author),
              (newSong.seconds = 204),
              (newSong.cover = song.image),
              (newSong.src = song.path),
              (newSong.related_songs = song.related_songs),
              (newSong.bpm = song.bpm),
              (newSong.key = song.key),
              (newSong.scale = song.scale),
              (newSong.danceability = song.danceability),
              (newSong.happy = song.happy),
              (newSong.sad = song.sad),
              (newSong.played = false);
            this.songs.push(newSong);
          });

          console.log({ songs_after: this.songs });
        })
        .catch(err => {
          console.log(err);
        });

      var placeholder = this.songs[0];
      var indexPlaceholder = this.songs.indexOf(placeholder);
      this.songs.splice(indexPlaceholder, 1);

      this.currentPage++;

      console.log(["this.currentPage", this.currentPage]);
      return allSongs;
    },

    nextPage(pageNumber) {
      console.log(["this.nextPage", this.currentPage]);
      this.getAllSongFromApi(pageNumber);
    },
    getRelatedSongs(song) {
      //  let related_url = song.related_songs ?? 'http://mage.tech:8899/api/songs/match/'+song.title
      let related_url = song.related_songs;

      console.log({ related_url });

      axios
        .get(related_url)
        .then(res => {
          let songs = res.data.hits;
          let related_songs = res.data.hits;
          console.log({ related_songs });

          songs.forEach(song => {
            let newSong = song;
            (newSong.title = song.title),
              (newSong.artist = song.author),
              (newSong.seconds = 204),
              (newSong.cover = song.image),
              (newSong.src = song.path),
              (newSong.related_songs = song.related_songs),
              (newSong.bpm = song.bpm),
              (newSong.key = song.key),
              (newSong.scale = song.scale),
              (newSong.danceability = song.danceability),
              (newSong.happy = song.happy),
              (newSong.sad = song.sad),
              (newSong.played = false);

            this.matches.push(newSong);
          });
        })
        .catch(err => {
          console.log(err);
        });
      // return matches;
    },

    getNextRelatedSongs(song) {
      //   let url  = 'http://mage.tech:8899/api/songs/match/'+song.title
      let url = song.related_songs;
      console.log({ url });
      axios
        .get(url)
        .then(res => {
          let songs = res.data.hits;
          console.log(songs);

          songs.forEach(song => {
            let newSong = song;
            (newSong.title = song.title),
              (newSong.artist = song.author),
              (newSong.seconds = 204),
              (newSong.cover = song.image),
              (newSong.src = song.path),
              (newSong.related_songs = song.related_songs),
              (newSong.bpm = song.bpm),
              (newSong.key = song.key),
              (newSong.scale = song.scale),
              (newSong.danceability = song.danceability),
              (newSong.happy = song.happy),
              (newSong.sad = song.sad),
              (newSong.played = false);

            this.songs.push(newSong);
          });
        })
        .catch(err => {
          console.log(err);
        });
      // return matches;
    },

    getDataFromWebSocket() {
      let appKey = "local";
      const socket = new WebSocket(
        "ws://mage.tech:6001/socket/song?appKey=" + appKey
      );
      socket.onopen = function() {
        console.log("OPEN FOR NOW !!!");
      };

      this.socket = socket;

      socket.onmessage = function(msg) {
        console.log(msg);
        console.log({
          message_socket: msg.data
        });
      };

      // eslint-disable-next-line no-unused-vars
      let data = {
        id: 1,
        name: "atem",
        source: "Music App FE"
      };

      setTimeout(function() {
        //alert("Sup!");
        socket.send(JSON.stringify(data));
        console.log(data);
      }, 2000); //wait 2 seconds
    },

    sendData(song) {
      let data = {
        song
      };

      this.socket.send(JSON.stringify(data));
      console.log(data);
    },

    replaceCurrent(song) {
      this.current.isPlaying = false;
      console.log(this.current.src);
      console.log(song.path);
      var clearButton = document.querySelector("[title='Clear']");
      console.log({ clearButton });
      clearButton.click();

      console.log({
        song: song
      });

      console.log({
        current: this.current
      });
      this.current = song;
      this.current.src = song.path;
      this.current.cover = song.image;
      this.current.id = song.objectID;
      this.current.isPlaying = true;

      this.play(song);
    },

    searchSong() {
      var impput = document.querySelector("[aria-label='Search']");

      // change style of input
      impput.style.backgroundColor = "blue";
      // click search button
      impput.click();
      impput.value = this.search;
      console.log({ impput });
    }
  },
  mounted() {
    this.getDataFromWebSocket();
    this.getAllSongFromApi();
    this.songs = threatSongs(this.songs);
    this.current = this.songs[this.index];
    this.player.src = this.current.src;
  }
};
</script>

<style>
@import "./assets/styles/main.css";
</style>
