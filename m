From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 6/7] [RFC] Support multiply-bindable cgroup subsystems
Date: Wed, 18 Mar 2009 10:09:47 +0800
Message-ID: <49C057EB.1000307@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>	<20090312105147.24154.62638.stgit@menage.corp.google.com>
	<49BF4744.5060309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49BF4744.5060309-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

>>  			cgrp->subsys[i] = NULL;
>>  			root->subsys_bits &= ~bit;
>> -			rootnode.subsys_bits |= bit;
>> +			if (singleton)
>> +				rootnode.subsys_bits |= bit;
> 
> initially we can see all subsystems in /proc/cgroups, but:
> 

Ah, I just notice debug_subsys will never be in rootnode. But this is a bit odd,
and one of the use of /proc/cgroups is to check if a subsystem is supported or
not, so we can no longer do this:
	#! /bin/sh
	grep -q debug /proc/cgroups
	if [ $? -ne 0 ]; then
		echo "debug subsystem is not compiled into kernel"
		exit 1
	fi
	# mount debug_subsys and do something with it...
