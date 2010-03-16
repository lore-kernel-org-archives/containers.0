From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] block: make CONFIG_BLK_CGROUP visible
Date: Tue, 16 Mar 2010 09:36:41 +0800
Message-ID: <4B9EE0A9.5010901@cn.fujitsu.com>
References: <4B9DA6F5.3070606@cn.fujitsu.com> <20100315132149.GA21127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100315132149.GA21127@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Gui Jianfeng <GuiJianfeng@cn.fujitsu.com>, Ben Blum <bblum@andrew.cmu.edu>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

>>  	---help---
>>  	Generic block IO controller cgroup interface. This is the common
>> @@ -91,7 +92,7 @@ config BLK_CGROUP
>>  	to such task groups.
>>  
>>  config DEBUG_BLK_CGROUP
>> -	bool
>> +	bool "Block cgroup debugging help"
> 
> 
> Why are you making DEBUG_BLK_CGROUP this as a user visible/configurable
> option? This is already controlled by DEBUG_CFQ_IOSCHED. If you don't want
> the DEBUG overhead, just set DEBUG_CFQ_IOSCHED=n and DEBUG_BLK_CGROUP will
> not be selected? Making it user visible does not seem to be buying us
> anything?
> 

Sounds reasonable. A minor question, since DEBUG_BLK_CGROUP is not
visible, the help message for this config is not visible too, so we
still keep it?
