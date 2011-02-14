From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v8 0/3] cgroups: implement moving a threadgroup's threads
	atomically with cgroup.procs
Date: Sun, 13 Feb 2011 22:12:51 -0800
Message-ID: <AANLkTim7t8zBUcuVbmPQYuqjB1ZDQtrrpLtVRqT=PgDy__21302.2719523453$1297664210$gmane$org@mail.gmail.com>
References: <20101226120919.GA28529@ghc17.ghc.andrew.cmu.edu>
	<20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110209151046.89e03dcd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110209151046.89e03dcd.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Feb 9, 2011 at 3:10 PM, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> w=
rote:
> On Mon, 7 Feb 2011 20:35:42 -0500
> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
>
>> On Sun, Dec 26, 2010 at 07:09:19AM -0500, Ben Blum wrote:
>> > On Fri, Dec 24, 2010 at 03:22:26AM -0500, Ben Blum wrote:
>> > > On Wed, Aug 11, 2010 at 01:46:04AM -0400, Ben Blum wrote:
>> > > > On Fri, Jul 30, 2010 at 07:56:49PM -0400, Ben Blum wrote:
>> > > > > This patch series is a revision of http://lkml.org/lkml/2010/6/2=
5/11 .
>> > > > >
>> > > > > This patch series implements a write function for the 'cgroup.pr=
ocs'
>> > > > > per-cgroup file, which enables atomic movement of multithreaded
>> > > > > applications between cgroups. Writing the thread-ID of any threa=
d in a
>> > > > > threadgroup to a cgroup's procs file causes all threads in the g=
roup to
>> > > > > be moved to that cgroup safely with respect to threads forking/e=
xiting.
>> > > > > (Possible usage scenario: If running a multithreaded build syste=
m that
>> > > > > sucks up system resources, this lets you restrict it all at once=
 into a
>> > > > > new cgroup to keep it under control.)
>> > > > >
>
> The above six month old text is the best (and almost the only)
> explanation of the rationale for the entire patch series. =A0Is
> it still correct and complete?
>

It's still correct, but I'm sure we could come up with a more detailed
justification if necessary.

Paul
