From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] block: make CONFIG_BLK_CGROUP visible
Date: Tue, 16 Mar 2010 09:42:59 +0800
Message-ID: <4B9EE223.7020302@cn.fujitsu.com>
References: <4B9DA6F5.3070606@cn.fujitsu.com> <20100315115724.GK5768@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100315115724.GK5768@kernel.dk>
Sender: linux-kernel-owner@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Gui Jianfeng <GuiJianfeng@cn.fujitsu.com>, Ben Blum <bblum@andrew.cmu.edu>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Jens Axboe wrote:
> On Mon, Mar 15 2010, Li Zefan wrote:
>> Make the config visible, so we can choose from CONFIG_BLK_CGROUP=y
>> and CONFIG_BLK_CGROUP=m when CONFIG_IOSCHED_CFQ=m.
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> What kernel is this against?
> 

It's against linus' tree. I've just checked the block tree, and found
it needs to be synced, otherwise this patch can't be applied on it.
