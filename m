From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Per-instance devpts
Date: Fri, 01 Aug 2008 11:12:21 -0700
Message-ID: <48935205.3090807@zytor.com>
References: <20080412172933.GA19295@us.ibm.com>
	<1208027215.28187.17.camel@x61.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1208027215.28187.17.camel-xJGG6ySDJhrj0SQisxZUdA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Since the issue of PTY namespaces came up (and was rejected) back in 
April, I have thought a little bit about changing ptys to be tied 
directly into a devpts instance.  devpts would then be a "normal" 
filesystem, which can be mounted multiple times (or not at all).  pty's 
would then become private to a devpts instance.

This is what it would appear would have to change, and I'd like to get 
people's feeing for the user-space impact:

1. /dev/ptmx would have to change to a symlink, ptmx -> pts/ptmx.
2. Permissions on /dev/ptmx would not be persistent, and would have to
    be set via devpts mount options (unless they're 0666 root.tty, which
    would presumably be the default.)
3. The /proc/sys/kernel/pty limit would be global; a per-filesystem
    limit could be added on top or instead (presumably via a filesystem
    mount options.)

I worry #1 would have substantial user-space impact, but I don't see a 
way around it, since there would be no obvious way to associate 
/dev/ptmx with a filesystem.

	-hpa
