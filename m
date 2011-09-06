From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Wed, 7 Sep 2011 02:33:41 +0900
Message-ID: <20110906173341.GM18425@mtj.dyndns.org>
References: <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <20110901080508.GF30615@sun>
 <20110902163711.GA3124@albatros>
 <20110905185358.GA2103@albatros>
 <20110905192009.GJ761@sun>
 <20110905194908.GA2690@albatros>
 <20110905203627.GL761@sun>
 <20110906101518.GA4799@albatros>
 <20110906165144.GJ18425@mtj.dyndns.org>
 <20110906172952.GA28055@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110906172952.GA28055@albatros>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

Hello,

On Tue, Sep 06, 2011 at 09:29:52PM +0400, Vasiliy Kulikov wrote:
> I agree with you.  I don't think that showing system-global debug
> information to all users by default is the right thing.  But some people
> doesn't agree with this point of view:
> 
> http://thread.gmane.org/gmane.linux.kernel/1108378

Yeap, I know there are two sides of the discussion but if one takes
the position that hiding such global debug info is more harmful, it's
only crazier to hide such information from each individual users of
the said global facility.  So, let's just forget about information
leak via freeing or not freeing here.  It's the wrong battle field.

Thanks.

-- 
tejun
