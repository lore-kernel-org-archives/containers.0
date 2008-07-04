From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 01/15] kobject: Cleanup kobject_rename and !CONFIG_SYSFS
Date: Fri, 04 Jul 2008 15:33:23 +0900
Message-ID: <486DC433.9040200@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr>	<20080618170731.002784342@theryb.frec.bull.fr>	<485F04E1.70204@gmail.com> <m1y74svtff.fsf@frodo.ebiederm.org>	<486706C9.9040303@gmail.com> <m18wwmsqdv.fsf@frodo.ebiederm.org>	<4869D314.5030403@gmail.com> <m1ej6enep7.fsf@frodo.ebiederm.org>	<486A0751.9080602@gmail.com> <m1wsk5hjm0.fsf@frodo.ebiederm.org>	<486AF4FA.8020805@gmail.com> <m1ej6d9c2r.fsf@frodo.ebiederm.org>	<486B060C.7030607@gmail.com> <m14p78s02q.fsf@frodo.ebiederm.org>	<486C4515.1070007@gmail.com> <m1hcb7o8lv.fsf@frodo.ebiederm.org>	<486CB051.5000507@fr.ibm.com> <m14p77m9uy.fsf@frodo.ebiederm.org>	<486CF71F.5090405@gmail.com> <m1y74iiidz.fsf_-_@frodo.ebiederm.org> <m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> It finally dawned on me what the clean fix to sysfs_rename_dir
> calling kobject_set_name is.  Move the work into kobject_rename
> where it belongs.  The callers serialize us anyway so this is
> safe.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Nice clean up.  Acked-by: Tejun Heo <tj@kernel.org>

-- 
tejun
