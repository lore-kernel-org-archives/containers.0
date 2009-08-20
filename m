From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/8] Revert commit 8827c288feb7810185aa7c2e37537202fc709869
Date: Wed, 19 Aug 2009 21:49:51 -0700
Message-ID: <6599ad830908192149o4dc4d4a2p32fbce972a949d0e__27061.9295108647$1250743839$gmane$org@mail.gmail.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235812.22531.76212.stgit@menage.mtv.corp.google.com>
	<4A8CB62F.8030504@cn.fujitsu.com>
	<6599ad830908191941x6ee47d58x295c29f80f8c624c@mail.gmail.com>
	<4A8CBEDC.6010709@cn.fujitsu.com>
	<6599ad830908192013p328a2256o8c807a160e25a9a3@mail.gmail.com>
	<20090820044059.GE29801@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090820044059.GE29801-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 19, 2009 at 9:40 PM, Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Aug 19, 2009 at 08:13:59PM -0700, Paul Menage wrote:
>> On Wed, Aug 19, 2009 at 8:11 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> >
>> > As you said, the 2 patches differ just in using different var/func
>> > names, so rebasing shouldn't be hard but maybe a bit boring.
>> >
>>
>> Yes - it's a fair amount of work for no real gain.
>
> So this revert won't introduce a regression for any potential tests?
>

Yes, there would be a two-commit window where a hypothetical test that
tests for concurrent opens of "tasks" files from different pid
namespaces would fail.

If that was really a big deal, then it wouldn't be too hard to fold
the first three patches in this series down into one, but that would
reduce the clarity of the commit history.

Paul
