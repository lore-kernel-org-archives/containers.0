From: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Mon, 11 Aug 2008 17:14:33 -0600
Message-ID: <20080811171433.2ce81f28__33033.039890188$1218496692$gmane$org@bike.lwn.net>
References: <20080807224033.FFB3A2C1@kernel> <200808111853.13854.arnd@arndb.de>
	<1218484114.5598.43.camel@nimitz>
	<200808112347.50245.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200808112347.50245.arnd-r2nGTMty4D4@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 11 Aug 2008 23:47:49 +0200
Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:

> The other problem that you really need to solve is interface
> stability. What you are creating is a binary representation
> of many kernel internal data structures, so in our common
> rules, you have to make sure that you remain forward and
> backward compatible. Simply saying that you need to run
> an identical kernel when restarting from a checkpoint is not
> enough IMHO.

OTOH, making one of these checkpoint files go into any 2.6.x kernel
seems like a very high bar, to the point, perhaps, of killing this
feature entirely.  

There could be a case for viewing sys_restore() as being a lot like
sys_init_module() - a view into kernel internals that goes beyond the
normal user-space ABI, and beyond the stability guarantee.  It might be
possible to create a certain amount of version portability with a
modversions-like mechanism, but it sure seems hard to do better than
that.

jon
