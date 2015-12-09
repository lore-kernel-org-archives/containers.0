From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: piping core dump to a program escapes container
Date: Tue, 08 Dec 2015 21:29:13 -0600
Message-ID: <876108fgfq.fsf__7918.54530475593$1449632277$gmane$org@x220.int.ebiederm.org>
References: <CABAubTgj8+xngrvc7sNbYS_Hq+-rGAYCz0y433ByiZ45dZuT0w@mail.gmail.com>
	<56679161.303@cn.fujitsu.com> <56679399.6080306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <56679399.6080306-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Dongsheng Yang's message of
	"Wed, 9 Dec 2015 10:36:09 +0800")
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shayan Pooya <shayan-UQzSddOuLosdnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
List-Id: containers.vger.kernel.org

Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> On 12/09/2015 10:26 AM, Dongsheng Yang wrote:
>> On 10/25/2015 05:54 AM, Shayan Pooya wrote:
>>> I noticed the following core_pattern behavior in my linux box while
>>> running docker containers. I am not sure if it is bug, but it is
>>> inconsistent and not documented.
>>>
>>> If the core_pattern is set on the host, the containers will observe
>>> and use the pattern for dumping cores (there is no per cgroup
>>> core_pattern). According to core(5) for setting core_pattern one can:
>>>
>>> 1. echo "/tmp/cores/core.%e.%p" > /proc/sys/kernel/core_pattern
>>> 2. echo "|/bin/custom_core /tmp/cores/ %e %p " >
>>> /proc/sys/kernel/core_pattern
>>>
>>> The former pattern evaluates the /tmp/cores path in the container's
>>> filesystem namespace. Which means, the host does not see a core file
>>> in /tmp/cores.
>>>
>>> However, the latter evaluates the /bin/custom_core path in the global
>>> filesystem namespace. Moreover, if /bin/core decides to write the core
>>> to a path (/tmp/cores in this case as shown by the arg to
>>> custom_core), the path will be evaluated in the global filesystem
>>> namespace as well.
>>>
>>> The latter behaviour is counter-intuitive and error-prone as the
>>> container can fill up the core-file directory which it does not have
>>> direct access to (which means the core is also not accessible for
>>> debugging if someone only has access to the container).

From a container perspective it is perhaps counter intuitive from
the perspective of the operator of the machine nothing works specially
about core_pattern and it works as designed with no unusual danages.

>> Hi Shayan,
>>      We found the same problem with what you described here.
>> Is there any document for this behaviour? I want to know is
>> that intentional or as you said a 'bug'. Maybe that's intentional
>> to provide a way for admin to collect core dumps from all containers as
>> Richard said. I am interested in it too.
>>
>> Anyone can help here?
>
> In addition, is that a good idea to make core_pattern to be seperated
> in different namespace?

The behavior was the best we could do at the time last time this issue
was examined.    There is enough information available to be able to
write a core dumping program that can reliably place your core dumps
in your container.

There has not yet been an obvious namespace in which to stick
core_pattern, and even worse exactly how to appropriate launch a process
in a container has not been figured out.

If those tricky problems can be solved we can have a core_pattern in a
container.  What we have now is the best we have been able to figure out
so far.

Eric


>
> Yang
>>
>> Yang
>>>
>>> Currently, I work around this issue by detecting that the process is
>>> crashing from a container (by comparing the namespace pid to the
>>> global pid) and refuse to dump the core if it is from a container.
>>>
>>> Tested on Ubuntu (kernel 3.16) and Fedora (kernel 4.1).
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe cgroups" in
>>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>> .
>>
