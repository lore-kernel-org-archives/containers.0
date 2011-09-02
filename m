From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 2 Sep 2011 11:07:10 +0300
Message-ID: <20110902080710.GA12920@shutemov.name>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <4E603758.6050003@gmail.com>
 <20110902015807.GG2752@htj.dyndns.org>
 <4E6039BA.1010805@gmail.com>
 <20110902022957.GH2752@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110902022957.GH2752@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Nicholas Miell <nmiell@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Vasiliy Kulikov <segoon@openwall.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Fri, Sep 02, 2011 at 11:29:57AM +0900, Tejun Heo wrote:
> Hello,
> 
> On Thu, Sep 01, 2011 at 07:04:42PM -0700, Nicholas Miell wrote:
> > So are the filenames in /proc/$PID/map_files/ guaranteed to be identical
> > to the first field (first two fields? the part before the first space)
> > in /proc/$PID/maps?
> 
> Yeap, naturally.

Except zero padding. %08lx in maps and %lx in map_files.

-- 
 Kirill A. Shutemov
