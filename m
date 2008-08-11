From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Mon, 11 Aug 2008 10:11:45 -0700
Message-ID: <1218474705.5598.17.camel__40935.1399787285$1218474936$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<200808090013.41999.arnd@arndb.de> <20080811152201.GB25930@us.ibm.com>
	<200808111853.13854.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200808111853.13854.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2008-08-11 at 18:53 +0200, Arnd Bergmann wrote:
> The best way I can think of for this would be to use existing syscalls
> (e.g. sched_setscheduler, setfsuid, ...) from user space whereever
> possible and do only the bare minimum for the restart part in the
> kernel.

Well, the current direction is about as far away from that as you can
get, unless we basically call those system calls from inside our new
sys_restart() one.  As of now, we're as much work in the kernel as
possible, and doing the bare minimum in userspace.  That's what both
Oren and our OpenVZ colleagues have advocated.

-- Dave
