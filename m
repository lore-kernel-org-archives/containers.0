From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Thu, 14 Aug 2008 08:12:16 -0700
Message-ID: <1218726736.23641.2.camel__36058.8596821346$1218726984$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<200808081146.54834.arnd@arndb.de> <1218221451.19082.36.camel@nimitz>
	<200808090013.41999.arnd@arndb.de> <1218234411.19082.58.camel@nimitz>
	<20080811150703.GA25930@us.ibm.com>  <20080814055301.GH6995@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080814055301.GH6995-+ZI9xUNit7I@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-08-14 at 07:53 +0200, Pavel Machek wrote:
> > As Oren has pointed out before, passing in an fd means we can pass a
> > socket into the syscall.
> 
> If you do pass a socket, will it handle blocking correctly? Getting
> deadlocked task would be bad. What happens if I try to snapshot into
> /proc/self/fd/0 ? Or maybe restore from /proc/cmdline?

Heh, that's a good point.  What was the other code where we kept coming
up with deadlocks like that?  Anyone remember?

-- Dave
