From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] OLS paper topics
Date: Wed, 30 Jan 2008 09:48:01 -0600
Message-ID: <20080130154801.GC1206@sergelap.austin.ibm.com>
References: <20080123195736.GA7823@sergelap.austin.ibm.com>
	<47990BAB.4050106@openvz.org>
	<20080124225002.GC13819@sergelap.austin.ibm.com>
	<47A03A73.6070408@openvz.org> <47A03C25.8030205@linux.vnet.ibm.com>
	<47A04916.50904@fr.ibm.com> <47A04A7A.9030701@linux.vnet.ibm.com>
	<47A07430.3000600@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47A07430.3000600-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
>
>> Why is that a conflict w.r.t resource management, isn't that more of a 
>> cgroup
>> feature - task migration. We need task migration for resource management, 
>> but
>> task migration is a system administrator/management function. I don't see 
>> the
>> conflict, but may be I am missing something very obvious.
>
> This is something we may want to dig. from a checkpoint/restart POV, a 
> 'container' acts a whole and you don't want tasks to be migrated from a 
> container to another. They have to share the same container properties.  
> it might be possible to solve that issue from user space or by making sure 
> a set of cgroups are dedicated to a container. 

This is certainly a good topic for the mini-summit.

The simple answer of course is you create a container for the virtual
server, then create containers within those around the applications you
want to checkpoint.  But depending on logistics (i.e. per-container
swapfiles) this could get complicated.

-serge
