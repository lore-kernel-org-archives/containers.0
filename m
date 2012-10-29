From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [V5 PATCH 08/26] memcontrol: use N_MEMORY instead
 N_HIGH_MEMORY
Date: Mon, 29 Oct 2012 14:08:05 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1210291405100.18552@chino.kir.corp.google.com>
References: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
	<1351524078-20363-7-git-send-email-laijs@cn.fujitsu.com>
	<20121029162212.GE20757@dhcp22.suse.cz>
	<alpine.DEB.2.00.1210291340100.18552@chino.kir.corp.google.com>
	<20121029205806.GB21640@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121029205806.GB21640-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: x86 maintainers <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Yasuaki ISIMATU <isimatu.yasuaki-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jiang Liu <jiang.liu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 29 Oct 2012, Michal Hocko wrote:

> > > > N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> > > > N_MEMORY stands for the nodes that has any memory.
> > > 
> > > What is the difference of those two?
> > > 
> > 
> > Patch 5 in the series 
> 
> Strange, I do not see that one at the mailing list.
> 

http://marc.info/?l=linux-kernel&m=135152595827692

> > introduces it to be equal to N_HIGH_MEMORY, so 
> 
> So this is just a rename? If yes it would be much esier if it was
> mentioned in the patch description.
> 

It's not even a rename even though it should be, it's adding yet another 
node_states that is equal to N_HIGH_MEMORY since that state already 
includes all memory.  It's just a matter of taste but I think we should be 
renaming it instead of aliasing it (unless you actually want to make 
N_HIGH_MEMORY only include nodes with highmem, but nothing depends on 
that).
