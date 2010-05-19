From: Mike Chan <mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] scheduler: cgroups cpuaccouting: Make cpuusage atomic
Date: Wed, 19 May 2010 12:31:27 -0700
Message-ID: <AANLkTilgcX0fHfGSyNRBsc257SsnZ4T3LNWvXb0VNseo__44870.3733076856$1274297749$gmane$org@mail.gmail.com>
References: <1274264877.5605.10541.camel@twins>
	<1274295539-7798-3-git-send-email-trenn@suse.de>
	<1274295743.1674.1545.camel@laptop> <201005192113.52535.trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <201005192113.52535.trenn-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 19, 2010 at 12:13 PM, Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org> wrote:
> On Wednesday 19 May 2010 09:02:23 pm Peter Zijlstra wrote:
>> On Wed, 2010-05-19 at 20:58 +0200, Thomas Renninger wrote:
>> > and avoid locking on 32 bit.
>> > This resolves an ugly dependency in cgroups_cpuaccount.c
>> > to per_cpu runqueues lock variable.
>>
>> While I totally agree with the sentiments here, atomic64_t isn't
>> available on all 32bit archs and is _terribly_ expensive on ARCH=3Di386.
> Speed on i386 shouldn't count that much here.
> Big machines run x86_64 and cgroup cpu accounting doesn't make much
> sense on old i386 single core machines.
>

cpuacct can still be useful for single core machines, at least in
Android it tracks the cpu usage if your apps. On ARM I'm not sure
(maybe someone more knowledgeable can chime in) how much overhead this
will incur relative to scheduler / cpuacct overhead that's already
there.

Since this is a per-cpu value already, is it not sufficient to just
disable interrupts on that cpu while doing a normal u64 add for both
MP and UP systems?

-- Mike

> Would still be great to see the first patch go in then.
> The idea of splitting was to:
> =A0a) show the real change
> =A0b) make at least the first go in if the snd does not work out
>
> Thanks,
>
> =A0 =A0 Thomas
>
