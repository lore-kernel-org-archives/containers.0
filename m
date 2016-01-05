From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Propose] Isolate core_pattern in mnt namespace.
Date: Tue, 05 Jan 2016 01:58:34 -0600
Message-ID: <87k2nopidx.fsf@x220.int.ebiederm.org>
References: <56729B3D.1040502@cn.fujitsu.com> <56760F05.3020308@cn.fujitsu.com>
	<20151220023712.GT20997@ZenIV.linux.org.uk>
	<567616D6.6060202@cn.fujitsu.com>
	<87fuyx1mfn.fsf@x220.int.ebiederm.org>
	<567798EC.1040304@cn.fujitsu.com>
	<87twnbzcz8.fsf@x220.int.ebiederm.org>
	<567A1120.3070204@cn.fujitsu.com>
	<8760zpxgte.fsf@x220.int.ebiederm.org>
	<568B629E.5010806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <568B629E.5010806-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Dongsheng Yang's message of
	"Tue, 5 Jan 2016 14:28:46 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> On 12/24/2015 12:36 AM, Eric W. Biederman wrote:
>> Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> [...]
>
> Hi Eric,
> 	Happy new year and sorry for the late reply.
>>
>> Given the other constraints on an implementation the pid namespace looks
>> by far the one best suited to host such a sysctl if it is possible to
>> implement safely.
>
> So you think it's better to isolate the core_pattern in pid_namespace,
> am I right?

Roughly.

> But, core_file_path and user_mode_helper_path in core_pattern are much
> more related with mnt_namespace IMO.
>
> Could you help to explain it more?

You need a full complement of namespaces, to execute a user mode helper.

Really roughly you need a namespaced equivalent of kthreadd, with a full
complement of namespaces and cgroups setup in the container.

Further it is necessary to have a clear rule that says which processes
that dump core are affected.    For a hierarchical pid namespace this is
straight forward.  For a mount namespace I don't know how that could be
implemented.

And yes the whole kthreadd thing that user mode helper does to launch a
task is necessary to have a clean and predicatable environment.

Of course the default rule of dropping a file named core in the current
directory of the process that died works for everyone, with no kernel
modifications needed.

Eric
