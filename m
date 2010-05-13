From: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
Date: Thu, 13 May 2010 22:49:26 +0800
Message-ID: <AANLkTilanD4PlDpLqtTK7uE5o4aPgLhhYvYvVI37GycU__46693.8437115916$1273762232$gmane$org@mail.gmail.com>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
	<1273761576_4060@mail4.comsite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1273761576_4060-qolCYAvwHvWlVDA81TZ6el6hYfS7NtTn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Milton Miller <miltonm-ogEGBHC/i9Y@public.gmane.org>
Cc: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "James E.J. Bottomley" <James.Bottomley-l3A5Bk7waGM@public.gmane.org>, Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

T24gVGh1LCBNYXkgMTMsIDIwMTAgYXQgMTA6MzkgUE0sIE1pbHRvbiBNaWxsZXIgPG1pbHRvbm1A
YmdhLmNvbT4gd3JvdGU6Cj4gT24gVGh1LCAxMyBNYXkgMjAxMCBhdCAxNzo1MToyNSArMDgwMCwg
Q2hhbmdsaSBHYW8gd3JvdGU6Cj4KPj4gK3N0YXRpYyBpbmxpbmUgdm9pZCAqa3ZjYWxsb2Moc2l6
ZV90IG4sIHNpemVfdCBzaXplKQo+PiArewo+PiArIMKgIMKgIHJldHVybiBfX2t2bWFsbG9jKG4g
KiBzaXplLCBfX0dGUF9aRVJPKTsKPj4KPgo+IFRoaXMgbmVlZHMgbXVsdGlwbHkgb3ZlcmZsb3cg
Y2hlY2tpbmcgbGlrZSBrY2FsbG9jLgo+CgpUaGFua3MuCgotLSAKUmVnYXJkc++8jApDaGFuZ2xp
IEdhbyh4aWFvc3VvQGdtYWlsLmNvbSkKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxpc3QKQ29udGFpbmVyc0BsaXN0cy5s
aW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnL21h
aWxtYW4vbGlzdGluZm8vY29udGFpbmVycw==
