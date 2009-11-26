From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH RFC v0 3/3] memcg: implement memory thresholds
Date: Thu, 26 Nov 2009 18:27:38 +0200
Message-ID: <d977350fcc9bc3e1fe484440c1fc3a7470a4e26b.1259248846.git.kirill__11511.3253043548$1259252938$gmane$org@shutemov.name>
References: <cover.1259248846.git.kirill@shutemov.name>
	<bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259248846.git.kirill@shutemov.name>
	<8524ba285f6dd59cda939c28da523f344cdab3da.1259248846.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8524ba285f6dd59cda939c28da523f344cdab3da.1259248846.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
In-Reply-To: <cover.1259248846.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
References: <cover.1259248846.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

It allows to register multiple memory thresholds and gets notifications
when it crosses.

To register a threshold application need:
- create an eventfd;
- open file memory.usage_in_bytes of a cgroup
- write string "<event_fd> <memory.usage_in_bytes> <threshold>" to
  cgroup.event_control.

Application will be notified through eventfd when memory usage crosses
threshold in any direction.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

-- 
1.6.5.3
