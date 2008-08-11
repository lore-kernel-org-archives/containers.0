From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Mon, 11 Aug 2008 18:53:13 +0200
Message-ID: <200808111853.13854.arnd__18312.0912094184$1218473870$gmane$org@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <200808090013.41999.arnd@arndb.de>
	<20080811152201.GB25930@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080811152201.GB25930-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Monday 11 August 2008, Serge E. Hallyn wrote:
> At the restart end, every resource which was checkpointed will have to
> be re-created, and permissions checked against the privilege of the
> task which did the restart. =A0We may end up having to make use of the new
> credentials for this.
> =

> This could become unpleasant: if an unprivileged task asked a privileged
> helper to create something for the unprivileged task to use (i.e. a
> raw socket), then the user needs to be privileged to re-created the
> resource. =A0But it's necessary.

Right. Of course, the hard part here will be to make it obvious to
be safe. Having to check all sorts of permissions means there will
be many opportunities for exploitable bugs.

The best way I can think of for this would be to use existing syscalls
(e.g. sched_setscheduler, setfsuid, ...) from user space whereever
possible and do only the bare minimum for the restart part in the kernel.

	Arnd <><
