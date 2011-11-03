From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 3 Nov 2011 18:05:37 +0100
Message-ID: <20111103170532.GI8198@somewhere.redhat.com>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
	<4EB2C4A5.6000406@parallels.com>
	<20111103165903.GA4755@Debian-60-squeeze-64-minimal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111103165903.GA4755@Debian-60-squeeze-64-minimal>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Nov 03, 2011 at 05:59:03PM +0100, Max Kellermann wrote:
> On 2011/11/03 17:43, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> > I do have a couple of questions about this, but the most important
> > one is: Is this a competing implementation, or a cooperative effort
> > with Frederic's ?
> 
> Short answer: competing.
> 
> Long answer: I do not know Frederic's patch.  This is a repost of a
> patch that I submitted 9 months ago:
> 
>  https://lkml.org/lkml/2011/2/17/116
> 
> After little discussion, nobody seemed to be interested in it, and
> nobody merged it.  I reposted it today, not knowing somebody else had
> come up with a similar idea meanwhile.

Woops, sorry I never heard about it before I started working on this.
Otherwise I would have tried to work with you.
