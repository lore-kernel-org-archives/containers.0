From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Mon, 11 Aug 2008 16:23:14 -0700
Message-ID: <1218496994.5598.50.camel__38674.0066264339$1218497199$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<200808111853.13854.arnd@arndb.de> <1218484114.5598.43.camel@nimitz>
	<200808112347.50245.arnd@arndb.de>
	<20080811171433.2ce81f28@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080811171433.2ce81f28-vw3g6Xz/EtPk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2008-08-11 at 17:14 -0600, Jonathan Corbet wrote:
> On Mon, 11 Aug 2008 23:47:49 +0200
> Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> 
> > The other problem that you really need to solve is interface
> > stability. What you are creating is a binary representation
> > of many kernel internal data structures, so in our common
> > rules, you have to make sure that you remain forward and
> > backward compatible. Simply saying that you need to run
> > an identical kernel when restarting from a checkpoint is not
> > enough IMHO.
> 
> OTOH, making one of these checkpoint files go into any 2.6.x kernel
> seems like a very high bar, to the point, perhaps, of killing this
> feature entirely.  

The OpenVZ dudes like refer to something that Andrew Morton said about
this (paraphrasing...):  if we need cross-version restore support, we
can count on userspace to do the conversion.

You can almost think of it like the crashdump processing utility that we
have.  Instead of worrying about having the kernel *always* produce the
same crashdump with the same gunk in it, we make userspace do all the
parsing and interpretation.

It also makes it quite possible for a distribution to make a change (say
because of a security fix) in the kernel that changes the checkpoint
format, then to quickly code up the necessary bits for the conversion
program. 

-- Dave
