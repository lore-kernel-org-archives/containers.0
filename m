From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 07/15] sysfs: sysfs_chmod_file handle multiple superblocks
Date: Fri, 04 Jul 2008 15:44:34 +0900
Message-ID: <486DC6D2.6020303@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr>	<4869D314.5030403@gmail.com> <m1ej6enep7.fsf@frodo.ebiederm.org>	<486A0751.9080602@gmail.com> <m1wsk5hjm0.fsf@frodo.ebiederm.org>	<486AF4FA.8020805@gmail.com> <m1ej6d9c2r.fsf@frodo.ebiederm.org>	<486B060C.7030607@gmail.com> <m14p78s02q.fsf@frodo.ebiederm.org>	<486C4515.1070007@gmail.com> <m1hcb7o8lv.fsf@frodo.ebiederm.org>	<486CB051.5000507@fr.ibm.com> <m14p77m9uy.fsf@frodo.ebiederm.org>	<486CF71F.5090405@gmail.com> <m1y74iiidz.fsf_-_@frodo.ebiederm.org>	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>	<m1d4luihea.fsf_-_@frodo.ebiederm.org>	<m18wwiihbn.fsf_-_@frodo.ebiederm.org> <m14p76ih9a.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m14p76ih9a.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>, Linux Containers <containers@lists.osdl.org>, Benjamin Thery <benjamin.thery@bull.net>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Teach sysfs_chmod_file how to handle multiple sysfs superblocks.
> Since we only have one inode per sd the only thing we have to deal
> with is multiple dentries for sending fs notifications.  This might
> dup the inode notifications oh well.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Great, Acked-by: Tejun Heo <tj@kernel.org>

-- 
tejun
