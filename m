From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 0/2] Introduce /proc/pid/map_files v6
Date: Wed, 31 Aug 2011 11:58:14 +0400
Message-ID: <20110831075814.003575573@openvz.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Vasiliy Kulikov <segoon@openwall.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

Hi,

this series (I hope) do address all concerns on /proc/pid/map_files
feature. Since it needs to change proc_get_link arguments type --
such change was factored out into a separate patch.

Please review, comments/complains are *highly* appreciated!

Thanks,
  Cyrill
