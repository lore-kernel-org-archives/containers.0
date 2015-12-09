From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Subject: Re: piping core dump to a program escapes container
Date: Wed, 9 Dec 2015 09:34:18 +0100
Message-ID: <20151209093418.4d28b78c__12440.6204944991$1449650685$gmane$org@pluto.restena.lu>
References: <CABAubTgj8+xngrvc7sNbYS_Hq+-rGAYCz0y433ByiZ45dZuT0w@mail.gmail.com>
	<56679161.303@cn.fujitsu.com> <56679399.6080306@cn.fujitsu.com>
	<876108fgfq.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <876108fgfq.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shayan Pooya <shayan-UQzSddOuLosdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 08 Dec 2015 21:29:13 -0600 Eric W. Biederman wrote:
> Dongsheng Yang <yangds.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> 
> > On 12/09/2015 10:26 AM, Dongsheng Yang wrote:  
> >> On 10/25/2015 05:54 AM, Shayan Pooya wrote:  
> >>> I noticed the following core_pattern behavior in my linux box while
> >>> running docker containers. I am not sure if it is bug, but it is
> >>> inconsistent and not documented.
> >>>
> >>> If the core_pattern is set on the host, the containers will observe
> >>> and use the pattern for dumping cores (there is no per cgroup
> >>> core_pattern). According to core(5) for setting core_pattern one can:
> >>>
> >>> 1. echo "/tmp/cores/core.%e.%p" > /proc/sys/kernel/core_pattern
> >>> 2. echo "|/bin/custom_core /tmp/cores/ %e %p " >
> >>> /proc/sys/kernel/core_pattern
> >>>
> >>> The former pattern evaluates the /tmp/cores path in the container's
> >>> filesystem namespace. Which means, the host does not see a core file
> >>> in /tmp/cores.
> >>>
> >>> However, the latter evaluates the /bin/custom_core path in the global
> >>> filesystem namespace. Moreover, if /bin/core decides to write the core
> >>> to a path (/tmp/cores in this case as shown by the arg to
> >>> custom_core), the path will be evaluated in the global filesystem
> >>> namespace as well.
> >>>
> >>> The latter behaviour is counter-intuitive and error-prone as the
> >>> container can fill up the core-file directory which it does not have
> >>> direct access to (which means the core is also not accessible for
> >>> debugging if someone only has access to the container).  
> 
> From a container perspective it is perhaps counter intuitive from
> the perspective of the operator of the machine nothing works specially
> about core_pattern and it works as designed with no unusual danages.
> 
> >> Hi Shayan,
> >>      We found the same problem with what you described here.
> >> Is there any document for this behaviour? I want to know is
> >> that intentional or as you said a 'bug'. Maybe that's intentional
> >> to provide a way for admin to collect core dumps from all containers as
> >> Richard said. I am interested in it too.
> >>
> >> Anyone can help here?  
> >
> > In addition, is that a good idea to make core_pattern to be seperated
> > in different namespace?  
> 
> The behavior was the best we could do at the time last time this issue
> was examined.    There is enough information available to be able to
> write a core dumping program that can reliably place your core dumps
> in your container.
> 
> There has not yet been an obvious namespace in which to stick
> core_pattern, and even worse exactly how to appropriate launch a process
> in a container has not been figured out.
> 
> If those tricky problems can be solved we can have a core_pattern in a
> container.  What we have now is the best we have been able to figure out
> so far.

Isn't the second option dangerous if its run in global namespace and
settable from some other namespace/container?

If a process inside a container can set /proc/sys/kernel/core_pattern
then it could e.g. set it to
  echo "|/bin/rm -rf / /tmp/cores/ %e %p " > /proc/sys/kernel/core_pattern
and kill the host (eventually itself included).
Other command lines could do different bad things.


Something that would sound reasonable is to have the core dumping
helper process run under the namespaces the process which wrote to
/proc/sys/kernel/core_pattern had.
When some of those namespaces are gone, falling back to the namespaces
of the process for which core is to be dumped might seem reasonable
(or just not dumping core at all as is done when core_pipe_limit is
exceeded).

The value of core_pattern (and other core_* sysctls)  should probably belong
to the mount namespace the proc filesystem used for setting its value
was in - or the matching namespace of calling process when set via syscall.

Bruno
