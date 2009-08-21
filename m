From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 7/8] Adds functionality to read/write lock CLONE_THREAD
	fork()ing per-threadgroup
Date: Thu, 20 Aug 2009 21:50:07 -0700
Message-ID: <20090820215007.0e774abb.akpm@linux-foundation.org>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235843.22531.57310.stgit@menage.mtv.corp.google.com>
	<4A8CB750.7040509@cn.fujitsu.com>
	<6599ad830908191945k7c5f86b6j3ea4194f0dffa9ce@mail.gmail.com>
	<20090820141356.1bec84ed.akpm@linux-foundation.org>
	<20090821042403.GA25865@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090821042403.GA25865-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 21 Aug 2009 00:24:03 -0400 Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:

> On Thu, Aug 20, 2009 at 02:13:56PM -0700, Andrew Morton wrote:
> > On Wed, 19 Aug 2009 19:45:11 -0700
> > Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> > > On Wed, Aug 19, 2009 at 7:39 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> > > >
> > > >> + __ __ __ __ __ __ list_for_each_entry_rcu(p, &tsk->thread_group, thread_group) {
> > > >> + __ __ __ __ __ __ __ __ __ __ if (p->sighand) {
> > > >> + __ __ __ __ __ __ __ __ __ __ __ __ __ __ sighand = tsk->sighand;
> > 
> > (^^ who did that?)
> > 
> 
> The tsk->sighand? Likely me. I'm surprised it took that many pairs of eyes
> to catch it.

I was actually referring to the non-ascii crap in the email.

'twas Paul.
