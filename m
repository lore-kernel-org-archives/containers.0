From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Sat, 9 Aug 2008 00:39:19 +0200
Message-ID: <200808090039.20289.arnd__27729.3486557484$1218235329$gmane$org@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <200808090013.41999.arnd@arndb.de>
	<1218234411.19082.58.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218234411.19082.58.camel@nimitz>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Saturday 09 August 2008, Dave Hansen wrote:
> On Sat, 2008-08-09 at 00:13 +0200, Arnd Bergmann wrote:

> > Maybe you can invert the logic and let the new syscalls create a file
> > descriptor, and then have user space read or splice the checkpoint
> > data from it, and restore it by writing to the file descriptor.
> > It's probably easy to do using anon_inode_getfd() and would solve this
> > problem, but at the same time make checkpointing the current thread
> > hard if not impossible.
> =

> Yeah, it does seem kinda backwards. =A0But, instead of even having to
> worry about the anon_inode stuff, why don't we just put it in a fs like
> everything else? =A0checkpointfs!

Well, anon_inodes are really easy to use and have replaced some of the
simple non-mountable file systems in the kernel.

checkpointfs sounds interesting and I guess in a plan9 world of fairies
and fantasy, you should be able to create a checkpoint of your system using
'tar czf - /proc/', but I'm not sure it helps here.

The main problem I see with that would be atomicity: If you want multiple
processes to keep interacting with each other, you need to save them at
the same point in time, which gets harder as you split your interface into
more than a single file descriptor.

	Arnd <><
