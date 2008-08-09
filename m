From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Sat, 09 Aug 2008 06:39:25 -0700
Message-ID: <1218289165.19082.74.camel__8374.21553810618$1218289294$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<200808090039.20289.arnd@arndb.de> <1218242614.19082.65.camel@nimitz>
	<200808090837.07417.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200808090837.07417.arnd-r2nGTMty4D4@public.gmane.org>
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

On Sat, 2008-08-09 at 08:37 +0200, Arnd Bergmann wrote:
> On Saturday 09 August 2008, Dave Hansen wrote:
> > On Sat, 2008-08-09 at 00:39 +0200, Arnd Bergmann wrote:
> > > The main problem I see with that would be atomicity: If you want multiple
> > > processes to keep interacting with each other, you need to save them at
> > > the same point in time, which gets harder as you split your interface into
> > > more than a single file descriptor.
> > 
> > It could take ages to write out a checkpoint even to a single fd, so I
> > suspect we'd have the exact same kinds of issues either way.
> 
> I guess either way, you have to SIGSTOP (or similar) all the tasks you want
> to checkpoint atomically before you start saving the contents.
> If you use a single fd, you can do that under the covers, when using a 
> more complex file system, it seems more logical to require an explicit
> interface for this.

Oh, we're already working on patches to the freezer code to do this for
us.  There's a branch in here from Matt H. that's doing just that:

http://git.kernel.org/?p=linux/kernel/git/daveh/linux-2.6-next-lxc.git;a=shortlog

-- Dave
