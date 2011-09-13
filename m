From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 0/2] symlinks for mapped files in proc
Date: Wed, 14 Sep 2011 01:13:59 +0400
Message-ID: <20110913211359.674453213@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org
Cc: Kirill Shutemov <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Vasiliy Kulikov <segoon@openwall.com>
List-Id: containers.vger.kernel.org

Hi, since due to discussion on the patch "fs, proc: Introduce the
/proc/<pid>/map_files/ directory" it was found that better to split
it into two patches (in a sake of bisectability and non-intersection
in code touched) -- this series does it. Please review. I hope all
concerns are addressed this time. Complains are still welcome.

	Cyrill
