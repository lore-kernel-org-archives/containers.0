From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 0/2] fs, proc map_files new entry
Date: Tue, 25 Oct 2011 00:56:57 +0400
Message-ID: <20111024205657.807512807@openvz.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Nathan Lynch <ntl@pobox.com>, Andrew Morton <akpm@linux-foundation.org>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Vasiliy Kulikov <segoon@openwall.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

The fresh linux is out, so here the two patches were flowing around
for pretty long time. Now they are well tested and reviewed. While
c/r code is still under heavy development the /proc/map_files might
be useful for other purposes as well, so please give them a chance.

Cyrill
