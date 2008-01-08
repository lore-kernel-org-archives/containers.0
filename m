From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 0/9] mount ownership and unprivileged mount syscall (v6)
Date: Tue, 08 Jan 2008 12:35:02 +0100
Message-ID: <20080108113502.184459371@szeredi.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760738AbYAHLjk@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

After much sitting in -mm, Andrew dropped this patchset due to
conflicts with other stuff.  It would be nice, if it could be reviewed
in time for 2.6.26 (2.6.25 is closed as far as I understand).

v5 -> v6:

 - update to latest -mm
 - preliminary util-linux-ng support (will post right after this series)

Thanks,
Miklos

--
