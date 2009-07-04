From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH][BUGFIX] cgroups: fix pid namespace bug
Date: Sat, 04 Jul 2009 02:13:29 -0700
Message-ID: <m1ocs0dd52.fsf__9372.70273357189$1246699004$gmane$org@fess.ebiederm.org>
References: <4A4C0C60.4050106@cn.fujitsu.com>
	<6599ad830907011836x5eccc83eyc896a67295a6486d@mail.gmail.com>
	<4A4C18D5.7020806@cn.fujitsu.com>
	<6599ad830907011920r44df4022p53808b574da4a886@mail.gmail.com>
	<4A4C1B33.2030002@cn.fujitsu.com> <20090702132659.GA8051@us.ibm.com>
	<6599ad830907020843l7ce75abfq3e78b8f67a407ab9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907020843l7ce75abfq3e78b8f67a407ab9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Paul Menage's message of "Thu\, 2 Jul 2009 08\:43\:57 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> writes:

> On Thu, Jul 2, 2009 at 6:26 AM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>> Quoting Li Zefan (lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>>> Paul Menage wrote:
>>> > On Wed, Jul 1, 2009 at 7:17 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>> >> But I guess we are going to fix the bug for 2.6.31? So is it ok to
>>> >> merge a new feature 'cgroup.procs' together into 2.6.31?
>>> >>
>>> >
>>> > Does this bug really need to be fixed for 2.6.31? I didn't think that
>>> > the namespace support in mainline was robust enough yet for people to
>>> > use them for virtual servers in production environments.
>>
>> I don't know where the bar is for 'production environments', but I'd
>> have to claim that pid namespaces are there...
>
> Well, pid namespaces are marked as experimental, as are user
> namespaces (and were described as "very incomplete" a few months
> back). Pid namespaces are useful for process migration (which is still
> under development) or virtual servers (for which user namespaces are
> pretty much essential). So I'm not sure quite what you'd use pid
> namespaces for yet.

I have pid namespaces in pretty heavy use already.

Inescapable process groups are quite handy.

Eric
