From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 0/5] userns: bump idmap limits, fixes & tweaks
Date: Tue, 31 Oct 2017 18:46:32 -0500
Message-ID: <871sliubhj.fsf_-___11660.67393865$1509493634$gmane$org@xmission.com>
References: <20171024220441.10235-1-christian.brauner@ubuntu.com>
	<20171024220441.10235-2-christian.brauner@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20171024220441.10235-2-christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> (Christian
	Brauner's message of "Wed, 25 Oct 2017 00:04:41 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, tycho-E0fblnxP3wo@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Christian I have looked through your code and I have found one real
issue and of things I want to twak

The real issue is reading nr_extents multiple times when reading a map.
That can introduce races that will allow walking past the end of the
array, if the first read is 0 but the second read is > 5.

I have also found a couple of tweaks that look like they are worth
implementing.

As all of these are very small and very straight forward I have
tested these and applied them all to my for-next branch


Eric W. Biederman (5):
      userns: Don't special case a count of 0
      userns: Simplify the user and group mapping functions
      userns: Don't read extents twice in m_start
      userns: Make map_id_down a wrapper for map_id_range_down
      userns: Simplify insert_extent

 kernel/user_namespace.c | 159 ++++++++++++++++--------------------------------
 1 file changed, 51 insertions(+), 108 deletions(-)
