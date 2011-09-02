From: Nicholas Miell <nmiell@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v6
Date: Thu, 01 Sep 2011 19:04:42 -0700
Message-ID: <4E6039BA.1010805@gmail.com>
References: <20110831075814.003575573@openvz.org> <20110831080229.100652529@openvz.org> <4E603758.6050003@gmail.com> <20110902015807.GG2752@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110902015807.GG2752@htj.dyndns.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Vasiliy Kulikov <segoon@openwall.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On 09/01/2011 06:58 PM, Tejun Heo wrote:
> On Thu, Sep 01, 2011 at 06:54:32PM -0700, Nicholas Miell wrote:
>> This doesn't seem to fully export all the information passed to mmap(2)
>> -- it encompasses the addr, size, fd and (assuming the generated
>> symlink's permissions are accurate) prot parameters, but does nothing to
>> export the flags or offset parameters.
> 
> It looks like,
> 
> /proc/*/fd : fdinfo ~= map_files : maps
> 

So are the filenames in /proc/$PID/map_files/ guaranteed to be identical
to the first field (first two fields? the part before the first space)
in /proc/$PID/maps?

When I open a file in /proc/$PID/map_files/, is offset 0 the start of
the file on disk or is it the first byte of the mapping?
