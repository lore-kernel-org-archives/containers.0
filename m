From: Bruce Jones <bruce.jones-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Wed, 25 Mar 2009 12:21:19 -0600
Message-ID: <49CA761F.1020006@alcatel-lucent.com>
References: <4909B10A.8090403@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4909B10A.8090403-L+G57L1VLRbR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: Vivien Chappelier <vivien.chappelier-L+G57L1VLRbR7s880joybQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Vivien Chappelier wrote:
> Hi,
> 
> The recently introduced network namespaces allow separate standalone
>  network stacks to coexist on the same machine. This is a very useful
>  functionality that we have been needing and using in our products
> for some time, through the VRF ptchset
> (http://linux-vrf.sourceforge.net/). The goal of the VRF patchset and
> network namespaces are very similar, yet some features of the VRF are
> missing that these patches intend to provide.
> 
> 
Hi,

I have been a silent observer of the network namespace work for a few 
months. Like a couple of others, I also am interested in the functionality 
provided by the linux-vrf patches presented here by Vivien. Eric Biederman 
mentioned some sysfs patches that he was working on. Daniel Lezcano 
submitted a proposed new socketat syscall. Other than that this thread 
seems to have died a few months ago as far as I have been able to find. 

I would like to find out if there is any updated status. I offer my help 
in this effort. I am a new Linux developer, but I developed similar vrf 
features in a BSD-based stack under VxWorks.

Thanks,
Bruce
