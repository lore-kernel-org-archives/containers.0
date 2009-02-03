From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup mount point
Date: Mon, 2 Feb 2009 23:06:55 -0600
Message-ID: <20090203050654.GA11598__11916.2786555991$1233637750$gmane$org@us.ibm.com>
References: <20090202200013.GU3643@vespa.holoscopio.com>
	<1233606371.15779.32.camel@radis.liafa.jussieu.fr>
	<20090202205246.GA28593@glandium.org>
	<20090202214153.GV3643@vespa.holoscopio.com>
	<498779C2.2060908@nortel.com>
	<20090203121524.cdff11ae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090203121524.cdff11ae.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Chris Friesen <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, debian-devel-0aAXYlwwYIJuHlm7Suoebg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thadeu Lima de Souza Cascardo <cascardo-/wxwWNsM9nk+uJoB2kUjGw@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting KAMEZAWA Hiroyuki (kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org):
> On Mon, 02 Feb 2009 16:54:58 -0600
> "Chris Friesen" <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > Thadeu Lima de Souza Cascardo wrote:
> > 
> > > Linux Documentation is not consistent and have some funny options. In
> > > Documentation/cgroups/*, we have:
> > 
> > > So, we have some more options now: /cgroups, /containers, /dev/cpuset,
> > > /dev/cpuctl, /opt/cgroup, /opt/cpuset.
> > > 
> > > I am copying the container and the kernel guys. Perhaps, we can find an
> > > agreement (if we want to find one at all) and change all that
> > > Documentation to get consistent.
> > 
> > I'd vote for "cgroups" or "containers", mounted at / or /sys/.
> > 
> me, too.
> 
> But single mount point just assumes "all necessary subsystems are mounter at once"
> So,
>     /cgroup/<subsys>/       #this cannot handle multiple subsyses.
>     or 
>     /cgroup/some_nick_name  #just depends on users.
> 
> Hmm. Making documentation to use the same mount point is not so bad. But in real
> usage, cgroup's mount point seems case-by-case. 
> If libcgroup or libvirt shows some policy, it's good for users.
> 
>   /cgroup/<libcgroup's grouping nick name>/ ...

I'm lazy so I always use /cgroup or actually /cg.

I do the same thing with mounting /sys/kernel/security under /security,
so maybe /sys/cgroup actually makes sense :)

-serge
