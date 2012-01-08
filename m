From: Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH] Makefiles: Disable unused-variable warning
Date: Sun, 08 Jan 2012 16:01:17 +0100
Message-ID: <4F09AFBD.60503__42044.1909264357$1326034781$gmane$org@suse.cz>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
	<20111227135752.GK5344@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111227135752.GK5344-VqjxzfR4DlwKmadIfiO5sKVXKuFTiq87@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Dne 27.12.2011 14:57, Michal Hocko napsal(a):
> Anyway, I am wondering why unused-but-set-variable is disabled while
> unused-variable is enabled.

unused-but-set-variable was disabled, because it was a new warning in
gcc 4.6 and produced too much noise relatively to its severity. A make
W=1 build of x86_64_defconfig gives:
$ grep -c 'Wunused-but-set-variable' log
77
$ grep -c 'Wunused-variable' log
0

More exotic configuration will probably result in a couple of unused
variable warnings, but that IMO no reason to disable them globally.

> Shouldn't we just disable it as well rather
> than workaround this in the code? The warning is just pure noise in this
> case.

If it's noise in a particular case, there is always the option to add

CFLAGS_memcontrol.o := $(call cc-disable-warning, unused-variable)

to the respective Makefile.

Michal
