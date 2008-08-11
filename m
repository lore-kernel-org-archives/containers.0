From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Mon, 11 Aug 2008 17:54:15 -0400
Message-ID: <20080811175415.x7st9tf2ssg8og40__19650.8414963775$1218491956$gmane$org@cubmail.cc.columbia.edu>
References: <20080807224033.FFB3A2C1@kernel>
	<200808090013.41999.arnd@arndb.de> <20080811152201.GB25930@us.ibm.com>
	<200808111853.13854.arnd@arndb.de> <1218484114.5598.43.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218484114.5598.43.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org


Quoting Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>:

> Arnd, Jeremy and Oren,
>
> Thanks for all of the very interesting comments about the ABI.

I second that !

>
> Considering that we're still *really* early in getting this concept
> merged up into mainline, what do you all think we should do now?
>
> My main goal here is just to get everyone to understand the approach
> that we're proposing rather than to really fix the interfaces in stone.
> I bet we're going to be changing them a lot before these patches
> actually get in.

I closely follow the valuable feedback and fix the code accordingly.

I propose to extend the proof of concept, to also be able to save and
restore "simple" open files (regular files, directories). My motivation
is twofold:

(1) Providing eough functionality for people to meaningfully play
with the proposed patches and try them.

(2) Demonstrate how I propose to handle shared resources (open files).

The first point is very important because it makes the concept actually
useful to a much broader set of programs than otherwise. I hope this
will attract a larger audience :)

To this end, I have already extended the patchset, and I should be
able to send something working in a day or two.

Oren.
